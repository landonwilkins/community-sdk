//
//  FE_EngineWidget.m
//  emotivExampleSwift
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

#import "FE_EngineWidget.h"
#import <edk_ios/Iedk.h>

@implementation FE_EngineWidget

EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
EmoStateHandle eState				= IEE_EmoStateCreate();
int state                           = 0;
unsigned int userID                 = 0;
unsigned long trainedAction         = 0;
bool isConnected = false;
bool userAdded = false;

NSString *profilePath;
NSString *profileName;

NSDictionary *dictionaryAction = @{@"Neutral":[NSNumber numberWithInt:Facial_Neutral], @"Smile":[NSNumber numberWithInt:Facial_Smile], @"Clench":[NSNumber numberWithInt:Facial_Clench], @"Suprise":[NSNumber numberWithInt:Facial_Suprise], @"Frown":[NSNumber numberWithInt:Facial_Frown]};

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
                NSArray * array = [dictionaryAction allKeysForObject:[NSNumber numberWithInt:IS_FacialExpressionGetLowerFaceAction(eState)]];
                if(array.count > 0)
                    [self.delegate updateLowerFaceAction:[array objectAtIndex:0] power:IS_FacialExpressionGetLowerFaceActionPower(eState)];
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

-(void) setTrainingAction : (NSString *) action
{
    IEE_FacialExpressionAlgo_t act = (IEE_FacialExpressionAlgo_t)[dictionaryAction[action] integerValue];
    IEE_FacialExpressionSetTrainingAction(userID, act);
}

-(void) setTrainingControl : (FacialControl_t) control
{
    IEE_FacialExpressionSetTrainingControl(userID, (IEE_FacialExpressionTrainingControl_t)control);
}

-(void) clearTrainingData : (NSString *) action
{
    IEE_FacialExpressionAlgo_t act = (IEE_FacialExpressionAlgo_t)[dictionaryAction[action] integerValue];
    IEE_FacialExpressionSetTrainingAction(userID, act);
    IEE_FacialExpressionSetTrainingControl(userID, (IEE_FacialExpressionTrainingControl_t)FE_ERASE);
}

-(BOOL) isActionTrained : (NSString *) action
{
    IEE_FacialExpressionAlgo_t act = (IEE_FacialExpressionAlgo_t)[dictionaryAction[action] integerValue];
    return (trainedAction & act) != 0;
}

-(BOOL) isHeadsetConnected {
    return userAdded;
}

-(void) setSensitivity : (NSString *) action value : (int) value
{
    value = value * 100 + 500;
    IEE_FacialExpressionAlgo_t act = (IEE_FacialExpressionAlgo_t)[dictionaryAction[action] integerValue];
    IEE_FacialExpressionSetThreshold(userID, act, FE_SENSITIVITY, value);
}

-(int) getSensitivity : (NSString *) action
{
    int value = 0;
    IEE_FacialExpressionAlgo_t act = (IEE_FacialExpressionAlgo_t)[dictionaryAction[action] integerValue];
    IEE_FacialExpressionGetThreshold(userID, act, FE_SENSITIVITY, &value);
    value = (value - 500) / 100;
    return value;
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
