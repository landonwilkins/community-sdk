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

IEE_MotionDataChannel_t ChannelList[] = {
    IMD_TIMESTAMP, IMD_COUNTER, IMD_GYROX, IMD_GYROY, IMD_GYROZ, IMD_ACCX, IMD_ACCY, IMD_ACCZ, IMD_MAGX, IMD_MAGY, IMD_MAGZ
};

const char header[] = "TIMESTAMP, COUNTER,GYROX,GYROY,GYROZ, ACCX, ACCY,ACCZ, "
"IMD_MAGX, IMD_MAGY, IMD_MAGZ,";

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
                readytocollect = YES;
            }
            if(evenType == IEE_UserRemoved){
                NSLog(@"User Removed");
                readytocollect = NO;
            }
            if(evenType == IEE_EmoStateUpdated){
                
            }
        }
        if(readytocollect){
            IEE_MotionDataUpdateHandle(userid, hData);
            unsigned int nSamplesTaken=0;
            IEE_MotionDataGetNumberOfSample(hData,&nSamplesTaken);
            
            NSLog(@"Updated %d",nSamplesTaken);
            
            if(nSamplesTaken !=0){
                double *data = new double[nSamplesTaken];
                for(int sampleIdx=0; sampleIdx<(int)nSamplesTaken; ++sampleIdx){
                    for(int i=0 ; i< sizeof(ChannelList)/sizeof(IEE_MotionDataChannel_t) ; ++i)
                    {
                        IEE_MotionDataGet(hData, ChannelList[i], data, nSamplesTaken);
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
    hData           = IEE_MotionDataCreate();
    IEE_MotionDataSetBufferSizeInSec(1);

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
