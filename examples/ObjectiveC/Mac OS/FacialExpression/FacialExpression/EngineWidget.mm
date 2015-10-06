//
//  EngineWidget.m
//  FacialExpresison
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "EngineWidget.h"
#import <Edk/Iedk.h>

@implementation EngineWidget

EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
EmoStateHandle eState				= IEE_EmoStateCreate();
int state                           = 0;
unsigned int userID                 = 0;
unsigned long trainedAction         = 0;
bool isConnected = false;

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
                [self.delegate emoUpdateState:eState];
            }
        }
        if(eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            isConnected = true;
            if(self.delegate)
            {
                [self.delegate onHeadsetConnected];
            }
        }
        if(eventType == IEE_UserRemoved){
            NSLog(@"user remove");
            isConnected = false;
            if(self.delegate)
            {
                [self.delegate onHeadsetRemoved];
            }
        }
        if(eventType == IEE_FacialExpressionEvent) {
            IEE_FacialExpressionEvent_t mcevent = IEE_FacialExpressionEventGetType(eEvent);
            switch (mcevent) {
                case IEE_FacialExpressionTrainingCompleted:
                    [self checkSignature];
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingCompleted];
                    NSLog(@"complete");
                    break;
                case IEE_FacialExpressionTrainingStarted:
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingStarted];
                    NSLog(@"start");
                    break;
                case IEE_FacialExpressionTrainingFailed:
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingFailed];
                    NSLog(@"fail");
                    break;
                case IEE_FacialExpressionTrainingSucceeded:
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingSuccessed];
                    NSLog(@"success");
                    break;
                case IEE_FacialExpressionTrainingRejected:
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingRejected];
                    NSLog(@"reject");
                    break;
                case IEE_FacialExpressionTrainingReset:
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingDataReset];
                    NSLog(@"reset");
                    break;
                case IEE_FacialExpressionTrainingDataErased:
                    [self checkSignature];
                    if(self.delegate)
                        [self.delegate onFacialExpressionTrainingDataErased];
                    NSLog(@"erased");
                    break;
                default:
                    break;
            }
        }
    }
}

-(BOOL) setTrainingAction : (IEE_FacialExpressionAlgo_t) action
{
    int result = IEE_FacialExpressionSetTrainingAction(userID, action);
    return result == EDK_OK;
}

-(BOOL) setTrainingControl : (IEE_FacialExpressionTrainingControl_t) control
{
    int result = IEE_FacialExpressionSetTrainingControl(userID, control);
    return result == EDK_OK;
}

-(BOOL) clearTrainingData : (IEE_FacialExpressionAlgo_t) action
{
    int result1 = IEE_FacialExpressionSetTrainingAction(userID, action);
    int result2 = IEE_FacialExpressionSetTrainingControl(userID, (IEE_FacialExpressionTrainingControl_t)FE_ERASE);
    return (result1 == EDK_OK) & (result2 == EDK_OK);
}

-(BOOL) isActionTrained : (IEE_FacialExpressionAlgo_t) action
{
    return (trainedAction & action) != 0;
    
}

-(int) getTrainingTime {
    unsigned int value = 0;
    IEE_FacialExpressionGetTrainingTime(userID, &value);
    return value;
}

-(BOOL) isHeadsetConnected {
    return isConnected;
}

-(void) checkSignature
{
    IEE_FacialExpressionGetTrainedSignatureActions(userID, &trainedAction);
    int enableSignature = 0;
    if(IEE_FacialExpressionGetTrainedSignatureAvailable(0, &enableSignature))
        IEE_FacialExpressionSetSignatureType(userID, FE_SIG_TRAINED);
    if(self.delegate)
       [self.delegate onFacialExpressionTrainingSignatureUpdated];
}
@end
