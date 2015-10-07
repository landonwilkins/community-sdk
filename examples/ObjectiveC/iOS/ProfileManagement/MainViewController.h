//
//  MainViewController.h
//  ProfileManagement
//
//  Created by  EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <edk_ios/Iedk.h>

@interface MainViewController : UIViewController<UIAlertViewDelegate>{
    IBOutlet UIButton *btn_add_profile;
    IBOutlet UIButton *btn_rm_profile;
    IBOutlet UIButton *btn_set_profile;
    IBOutlet UIButton *btn_get_profile;
    
    EmoEngineEventHandle eEvent	;
    EmoEngineEventHandle eprofile;
    EmoStateHandle eState;
    unsigned int userID;
    bool connected ;
    int option;
    bool lock;
    unsigned int CONTROL_PANEL_PORT;
    UIAlertView *alertview;
    BOOL isSetProfile;
}
-(IBAction)AddProfile:(id)sender;
-(IBAction)RemoveProfile:(id)sender;
-(IBAction)SetProfile:(id)sender;
-(IBAction)GetProfile:(id)sender;
@end
