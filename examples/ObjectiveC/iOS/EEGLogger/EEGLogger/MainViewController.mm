//
//  MainViewController.m
//  EEGLogger
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2015 EmotivLifeSciences. All rights reserved.
//


/*This example only work with premium version*/

#import "MainViewController.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>

std::ofstream ofs;

IEE_DataChannel_t ChannelList[] = {
    IED_COUNTER, IED_AF3,IED_T7,IED_T8,
    IED_Pz, IED_AF4,IED_TIMESTAMP,
    IED_FUNC_ID, IED_FUNC_VALUE, IED_MARKER, IED_SYNC_SIGNAL
};

const char header[] = "COUNTER,AF3,T7,T8, Pz, AF4,TIMESTAMP, "
"FUNC_ID, FUNC_VALUE, MARKER, SYNC_SIGNAL,";

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
    eEvent			= IEE_EmoEngineEventCreate();
    emoState		= IEE_EmoStateCreate();
    userid			= 0;
    state  = 0;
    connected = NO;
    readytocollect = NO;
    lock = NO;
    isConnectBLE = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    documentDirectory = [paths lastObject];
}
-(IBAction)ConnectWithBLE:(id)sender{
    [btn_ble setEnabled:NO];
    
    isConnectBLE = YES;
    IEE_EmoInitDevice();
    IEE_EngineConnect();
    [self StartProgram];
}
-(IBAction)StopClick:(id)sender{
    [btn_ble setEnabled:YES];
    
    isConnectBLE = NO;
    readytocollect = NO;
    if(ofs.is_open()) ofs.close();
}
-(void)getInsightResult{
    while (1) {
        if(isConnectBLE){
            
            int couter = IEE_GetNumberDeviceInsight();
            /********Connect with Headset Insight*/
            if(couter > 0){
                if(!lock){
                    IEE_EmoConnectDevice(0);
                    //                    IEE_EmoSettingMode(MODE_EPOCPLUS_MOTION);
                    lock =true;
                }
                
            }
            else lock = false;
        }
        /*************************************/
        state = IEE_EngineGetNextEvent(eEvent);
        if(state == EDK_OK){
            IEE_Event_t evenType = IEE_EmoEngineEventGetType(eEvent);
            if(evenType == IEE_UserAdded){
                NSLog(@"User Adder");
                IEE_DataAcquisitionEnable(userid,true);
                readytocollect = YES;
            }
            if(evenType == IEE_UserRemoved){
                NSLog(@"User Removed");
                IEE_DataAcquisitionEnable(userid,false);
                readytocollect = NO;
            }
            if(evenType == IEE_EmoStateUpdated){
                
            }
        }
        if(readytocollect){
            IEE_DataUpdateHandle(userid, hData);
            unsigned int nSamplesTaken=0;
            IEE_DataGetNumberOfSample(hData,&nSamplesTaken);
            
            NSLog(@"Updated %d",nSamplesTaken);
            
            if(nSamplesTaken !=0){
                double *data = new double[nSamplesTaken];
                for(int sampleIdx=0; sampleIdx<(int)nSamplesTaken; ++sampleIdx){
                    for(int i=0 ; i< sizeof(ChannelList)/sizeof(IEE_DataChannel_t) ; ++i)
                    {
                        IEE_DataGet(hData, ChannelList[i], data, nSamplesTaken);
                        ofs << data[sampleIdx] << ",";
                    }
                ofs << std::endl;
                }
            delete [] data ;
           }
        }
        usleep(100);
    }
}
-(void)StartProgram{
    if (!connected) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getInsightResult) object:nil];
        thread.start;
        connected = YES;
    }
    hData           = IEE_DataCreate();
    IEE_DataSetBufferSizeInSec(1);

    /*************File .csv stored in folder Document of Application********************/
    NSString *path_file_csv = [NSString stringWithFormat:@"%@/test.csv",documentDirectory];
    NSLog(@"Path to file .csv %@",path_file_csv);
    ofs.open([path_file_csv cStringUsingEncoding:NSUTF8StringEncoding]);

    ofs << header << std::endl;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
