//
//  MainViewController.m
//  ProfileManagement
//
//  Created by  EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "MainViewController.h"
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <map>
#include <vector>
#include <fstream>
#include <iostream>
#include <sstream>


std::map<unsigned int,std::string> headsetProfileMap;
unsigned char* baseProfile = 0;
unsigned int baseProfileSize = 0;
std::map<std::string, std::string > _profiles;
typedef std::map<std::string, std::string >::iterator profileItr_t;
@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    alertview  = [[UIAlertView alloc]initWithTitle:@"Profile Name" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertview.alertViewStyle = UIAlertViewStylePlainTextInput;
    eEvent = IEE_EmoEngineEventCreate();
    eprofile = IEE_ProfileEventCreate();
    eState = IEE_EmoStateCreate();
    userID = 0;
    connected = false;
    CONTROL_PANEL_PORT = 3008;
    isSetProfile = NO;
    lock = false;
/**
 * Connect remote via port 3008 to ControlPanel app
 */
//    if(IEE_EngineRemoteConnect("127.0.0.1", CONTROL_PANEL_PORT)== EDK_OK)
//    {
//        NSLog(@"Emotiv Engine started")    ;
//        connected = TRUE;
//    }
    
    
/**
 * Connect with Bluetooth BLE (on device)
 */
    IEE_EmoInitDevice();
    if(IEE_EngineConnect() == EDK_OK){
        NSLog(@"Emotiv Engine started")    ;
        connected = TRUE;
    }

/****************************************************************/
    
    else
    {
        NSLog(@"Emotiv Engine failed !");
        connected = FALSE;
    }
    
    if(connected){
        [btn_add_profile setEnabled:YES];
        [btn_rm_profile setEnabled:YES];
        [btn_set_profile setEnabled:YES];
        [btn_get_profile setEnabled:YES];
        IEE_GetBaseProfile(eprofile);
        [self profileHandleToByteArray:eprofile :&baseProfile :&baseProfileSize ];
        
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getInsightResult) object:nil];
        thread.start;
    }
}
-(IBAction)AddProfile:(id)sender{
    option =1;
    [alertview show];
}
-(IBAction)RemoveProfile:(id)sender{
    option =2;
    [alertview show];
}
-(IBAction)SetProfile:(id)sender{
    option =3;
    [alertview show];
}
-(IBAction)GetProfile:(id)sender{
    option =4;
    [alertview show];
}
-(void)getInsightResult{
    while (1) {
        int couter = IEE_GetNumberDeviceInsight();
        /********Connect with Headset Insight*/
        if(couter > 0){
            if(!lock){
                IEE_EmoConnectDevice(0);
                lock =true;
            }
            
        }
        else lock = false;
        int state = IEE_EngineGetNextEvent(eEvent);
        if(state == EDK_OK){
            IEE_Event_t evenType = IEE_EmoEngineEventGetType(eEvent);
            IEE_EmoEngineEventGetUserId(eEvent, &userID);
            
            switch (evenType) {
                case IEE_UserAdded:{
                    NSLog(@"New user %i added.",userID);
                    
                    // add the headset
                    headsetProfileMap.insert(
                                             std::pair<unsigned int,std::string>(userID, std::string())
                                             );

                    break;
                }
                case IEE_UserRemoved:
                {
                    NSLog(@"User %i has been removed.",userID);
                    
                    // Profile will be returned as well, we need to save the profile according
                    // to the associated headset ID
                    
                    unsigned char* profileBuffer = 0;
                    unsigned int   profileSize   = 0;
                    
                    if ([self profileHandleToByteArray:eEvent :&profileBuffer :&profileSize])
                    {
                        std::map<unsigned int, std::string>::iterator iter = headsetProfileMap.find(userID);
                        
                        if (iter != headsetProfileMap.end())
                        {
                            const std::string& profileName = iter->second;
                            
                            if (!profileName.empty())
                            {
                                [self insertProfile:profileName :profileBuffer :profileSize];
                            }
                            
                            // Remove the headset ID from the mapping table
                            headsetProfileMap.erase(iter);
                        }
                    }
                    
                    if (profileBuffer) {
                        delete [] profileBuffer, profileBuffer = 0;
                    }
                    
                    break;
                }
                case IEE_EmoStateUpdated:
                {
                    IEE_EmoEngineEventGetEmoState(eEvent, eState);
                    break;
                }

                default:
                    break;
            }
        }
    }
    
    
}
-(BOOL)profileHandleToByteArray :(EmoEngineEventHandle)eProfile :(unsigned char**)profileBuffer :(unsigned int*)profileSize{
    assert(eProfile);
	assert(profileBuffer);
	assert(profileSize);
    
	if (*profileBuffer) {
		delete [] *profileBuffer, *profileBuffer = 0;
	}
	
	// Query the size of the profile byte stream
	BOOL ok = (IEE_GetUserProfileSize(eProfile, profileSize) == EDK_OK);
    
	if (ok && *profileSize > 0) {
        
		// Copy the content of profile byte stream into local buffer
		*profileBuffer = new unsigned char[*profileSize];
		ok = (IEE_GetUserProfileBytes(eProfile, *profileBuffer, *profileSize) == EDK_OK);
		
		if (!ok) {
			delete [] *profileBuffer, *profileBuffer = 0;
		}
	}
    
	return ok;

}

-(BOOL)insertProfile :(const std::string&)name :(const unsigned char*)profileBuf :(unsigned int)bufSize{
    assert(profileBuf);
	// Replace our stored bytes with the contents of the buffer passed by the caller
    std::string bytesIn(profileBuf, profileBuf+bufSize);
	_profiles[name] = bytesIn;
	return YES;
}
-(BOOL)isExist :(const std::string&)name{
    for ( profileItr_t itr = _profiles.begin(); itr != _profiles.end(); ++itr ) {
		if (itr->first == name) {
			return YES;
		}
	}
	return NO;
}
-(BOOL)removeProfile :(const std::string&)name{
    profileItr_t itr = _profiles.find(name);
	if ( itr == _profiles.end() ) return false;
	_profiles.erase(itr);
    
	return YES;
}
-(BOOL)extractProfile :(const std::string&)name :(unsigned char*)profileBuf :(unsigned int*)pBufSize{
    assert(pBufSize);
    
	// First, check to see if the designated profile exists
	profileItr_t itr = _profiles.find(name);
	if ( itr == _profiles.end() ) {
		*pBufSize = 0;
		return NO;
	}
    
	const std::string& refProfileBytes = itr->second;
    
	// Copy the contents of our binary profile string into the caller's buffer
	// (unless it's not big enough).
	if ( *pBufSize && (refProfileBytes.size() <= *pBufSize) && profileBuf ) {
		memcpy(profileBuf, refProfileBytes.data(), refProfileBytes.size());
		*pBufSize = (unsigned int) refProfileBytes.size();
	}
	else {
		*pBufSize = (unsigned int) refProfileBytes.size();
		return NO;
	}
    
	return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        NSString *profile_name = [alertView textFieldAtIndex:0].text;
        const std::string& profileName = [profile_name cStringUsingEncoding:NSUTF8StringEncoding];
        switch (option) {
            case 1:
            {
                NSLog(@"Add Profile...........");
                if(![self isExist:profileName]){
                    [self insertProfile:profileName :baseProfile :baseProfileSize];
                    NSLog(@"Profile %s added",profileName.c_str());
                    
                }
                
                else NSLog(@"Profile %s already existed",profileName.c_str());
                break;
            }
            case 2:
            {
                NSLog(@"Remove Profile...........");
                if([self isExist:profileName]){
                    [self removeProfile:profileName];
                    NSLog(@"Profile %s removed",profileName.c_str());
                
                // Remove the profile from the mapping table if it assoicated with a headset
				std::map<unsigned int,std::string>::iterator iter = headsetProfileMap.begin();
                
				for ( ; iter != headsetProfileMap.end(); iter++) {
					if (iter->second == profileName) {
						headsetProfileMap[iter->first] = std::string();
						break;
                        }
                    }
                }
                else NSLog(@"Profile %s not existed",profileName.c_str());
                break;
            }
            case 3:
            {
                NSLog(@"Set Profile .........");
                if([self isExist:profileName]){
					unsigned int profileSize = 1;
                    std::string profileBytes(profileSize, 0);
					// first call: enquiry profile size
					[self extractProfile:profileName :(unsigned char*)profileBytes.data() :&profileSize];
                    
                    profileBytes.resize(profileSize);
					// second call: extract the actual profile content
					if ([self extractProfile:profileName :(unsigned char*)profileBytes.data() :&profileSize]) {
                        
						// Set the binary profile into EmoEngine
						if(IEE_SetUserProfile(userID, (unsigned char*)profileBytes.c_str(), profileSize) == EDK_OK)
                        {
                            headsetProfileMap[userID] = profileName;
							NSLog(@"Profile %s set with the headset %d",profileName.c_str(),userID);
                            isSetProfile = YES;
                        }
						
					}

                }
                else NSLog(@"Profile %s not existed",profileName.c_str());
                break;
            }
            case 4:
            {
                NSLog(@"Get Profile .........");
                if([self isExist:profileName]){
                    if(isSetProfile){
                        if (IEE_GetUserProfile(userID, eprofile) == EDK_OK) {
                        
						unsigned int   profileSize   = 0;
						unsigned char* profileBuffer = 0;
						
						if ([self profileHandleToByteArray:eprofile :&profileBuffer :&profileSize]) {
                            
							std::map<unsigned int, std::string>::iterator iter
                            = headsetProfileMap.find(userID);
                            
							if (iter != headsetProfileMap.end()) {
								const std::string& profile = iter->second;
								
								if (!profile.empty() && !profile.compare(profileName)) {
									[self insertProfile:profile :profileBuffer :profileSize];
									NSLog(@"Profile %s acquired successfully.",profile.c_str());
								}
							}
						}
                        
						if (profileBuffer) {
							delete [] profileBuffer, profileBuffer = 0;
						}
					}
                    }
                    else NSLog(@"You must set profile first.");
                }
                else NSLog(@"Profile %s not existed",profileName.c_str());
                break;
            }
            default:
                break;
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
