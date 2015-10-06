//
//  ViewController.m
//  MotionDataLogger
//
//  Created by emotiv on 4/22/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "ViewController.h"
#import <edk/Iedk.h>

IEE_MotionDataChannel_t targetChannelList_Insight[] = {
    IMD_COUNTER,
    IMD_GYROX, IMD_GYROY, IMD_GYROZ, IMD_ACCX,
    IMD_ACCY, IMD_ACCZ, IMD_MAGX,IMD_MAGY,IMD_MAGZ,IMD_TIMESTAMP
};

BOOL isConnect = NO;
const char *headerStr_Insight = "COUNTER_MEMS, GYROX, GYROY, GYROZ, ACCX, ACCY, ACCZ, MAGX,MAGY,MAGZ,TIMESTAMP,";

const char *newLine = "\n";
const char *comma = ",";

@implementation ViewController

EmoEngineEventHandle eEvent;
EmoStateHandle eState;
DataHandle hData;

unsigned int userID					= 0;
float secs							= 1;
bool readytocollect					= false;
int state                           = 0;

NSFileHandle *file;
NSMutableData *data;

- (void)viewDidLoad {
    [super viewDidLoad];

    eEvent	= IEE_EmoEngineEventCreate();
    eState	= IEE_EmoStateCreate();
    hData   = IEE_MotionDataCreate();
    
    IEE_EmoInitDevice();
    
    if( IEE_EngineConnect() != EDK_OK ) {
        self.labelStatus.stringValue = @"Can't connect engine";
    }
    
    NSString* fileName = @"MotionDataLogger.csv";
    NSString* createFile = @"";
    [createFile writeToFile:fileName atomically:YES encoding:NSUnicodeStringEncoding error:nil];
    
    file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
    [self saveStr:file data:data value:headerStr_Insight];
    [self saveStr:file data:data value:newLine];
    
    IEE_MotionDataSetBufferSizeInSec(secs);
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(getNextEvent) userInfo:nil repeats:YES];
    
    // Do any additional setup after loading the view.
}

-(void) getNextEvent {
    int numberDevice = IEE_GetNumberDeviceInsight();
    if(numberDevice > 0 && !isConnect) {
        IEE_EmoConnectDevice(0);
        isConnect = YES;
    }
    int state = IEE_EngineGetNextEvent(eEvent);
    unsigned int userID = 0;
    
    if (state == EDK_OK)
    {
        
        IEE_Event_t eventType = IEE_EmoEngineEventGetType(eEvent);
        IEE_EmoEngineEventGetUserId(eEvent, &userID);
        
        // Log the EmoState if it has been updated
        if (eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            self.labelStatus.stringValue = @"Connected";
            readytocollect = TRUE;
        }
        else if (eventType == IEE_UserRemoved)
        {
            NSLog(@"User Removed");
            self.labelStatus.stringValue = @"Disconnected";
            readytocollect = FALSE;
            isConnect = NO;
        }
        else if (eventType == IEE_EmoStateUpdated)
        {
            
        }
    }
    if (readytocollect)
    {
        IEE_MotionDataUpdateHandle(0, hData);
        
        unsigned int nSamplesTaken=0;
        IEE_MotionDataGetNumberOfSample(hData,&nSamplesTaken);
        
        NSLog(@"Updated : %i",nSamplesTaken);
        if (nSamplesTaken != 0)
        {
            
            double* ddata = new double[nSamplesTaken];
            for (int sampleIdx=0 ; sampleIdx<(int)nSamplesTaken ; ++sampleIdx) {
                for (int i = 0 ; i<sizeof(targetChannelList_Insight)/sizeof(IEE_MotionDataChannel_t) ; i++) {
                    IEE_MotionDataGet(hData, targetChannelList_Insight[i], ddata, nSamplesTaken);
                    [self saveDoubleVal:file data:data value:ddata[sampleIdx]];
                    [self saveStr:file data:data value:comma];
                }
                [self saveStr:file data:data value:newLine];
            }
            delete[] ddata;
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void) saveStr : (NSFileHandle * )file data : (NSMutableData *) data value : (const char*) str
{
    [file seekToEndOfFile];
    data = [NSMutableData dataWithBytes:str length:strlen(str)];
    [file writeData:data];
}

-(void) saveDoubleVal : (NSFileHandle * )file data : (NSMutableData *) data value : (const double) val
{
    NSString* str = [NSString stringWithFormat:@"%f",val];
    const char* myValStr = (const char*)[str UTF8String];
    [self saveStr:file data:data value:myValStr];
}

@end
