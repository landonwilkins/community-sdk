//
//  ES_EngineWidget.m
//  emotivExampleSwift
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//


#import "ES_EngineWidget.h"
#import <edk_ios/Iedk.h>

@implementation ES_EngineWidget

EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
EmoStateHandle eState				= IEE_EmoStateCreate();
int state                           = 0;
unsigned int userID                 = 0;
bool isConnected = false;
bool userAdded = false;

-(id) init {
    self = [super init];
    if(self)
    {
        [self connectEngine];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getNextEvent) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void) connectEngine
{
    IEE_EmoInitDevice();
    IEE_EngineConnect();
}

-(void) connectEmoComposer
{
    IEE_EngineRemoteConnect("127.0.0.1", 1726);
}

-(void) getNextEvent {
    int couter_insight = IEE_GetNumberDeviceInsight();
    if(couter_insight > 0){
        if(!isConnected){
            IEE_EmoConnectDevice(0);
            isConnected=true;
        }
    }
    state = IEE_EngineGetNextEvent(eEvent);
    if(state == EDK_OK)
    {
        IEE_Event_t eventType = IEE_EmoEngineEventGetType(eEvent);
        int result = IEE_EmoEngineEventGetUserId(eEvent, &userID);
        
        if (result != EDK_OK) {
            NSLog(@"WARNING : Failed to return a valid user ID for the current event");
        }
        
        if(eventType == IEE_EmoStateUpdated ) {
            
            IEE_EmoEngineEventGetEmoState(eEvent, eState);
            if(self.delegate)
            {
                NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:IS_PerformanceMetricGetEngagementBoredomScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetRelaxationScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetExcitementLongTermScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetInstantaneousExcitementScore(eState)],nil];
                [self.delegate emoStateUpdate:array];
            }
        }
        if(eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            userAdded = true;
        }
        if(eventType == IEE_UserRemoved){
            NSLog(@"user remove");
            isConnected = false;
            userAdded = false;
        }
    }
}

-(BOOL) isHeadsetConnected {
    return userAdded;
}
@end
