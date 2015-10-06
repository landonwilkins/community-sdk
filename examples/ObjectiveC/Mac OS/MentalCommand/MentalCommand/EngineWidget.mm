//
//  EngineWidget.m
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "EngineWidget.h"


@implementation EngineWidget

EmoEngineEventHandle eEvent			= IEE_EmoEngineEventCreate();
EmoStateHandle eState				= IEE_EmoStateCreate();
int state                           = 0;
unsigned int userID                 = 0;
unsigned long trainedAction         = 0;
unsigned long activeAction          = 0;
bool isConnected = false;
bool userAdded = false;

NSString *profilePath;
NSString *profileName;

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

-(void) getNextEvent {
    int couter_insight = IEE_GetNumberDeviceInsight();
    if(couter_insight > 0){
        if(!isConnected){
            IEE_EmoConnectDevice(0);
            isConnected = true;
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
            IEE_MentalCommandAction_t action = IS_MentalCommandGetCurrentAction(eState);
            float power = IS_MentalCommandGetCurrentActionPower(eState);
            if(self.delegate)
                [self.delegate emoStateUpdate:action power:power];
        }
        if(eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            isConnected = true;
            IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
            IEE_MentalCommandGetActiveActions(userID, &activeAction);
            if(self.delegate)
                [self.delegate onHeadsetConnected];
        }
        if(eventType == IEE_UserRemoved){
            NSLog(@"user remove");
            isConnected = false;
            if(self.delegate)
                [self.delegate onHeadsetRemoved];
        }
        if(eventType == IEE_MentalCommandEvent) {
            IEE_MentalCommandEvent_t mcevent = IEE_MentalCommandEventGetType(eEvent);
            switch (mcevent) {
                case IEE_MentalCommandTrainingCompleted:
                    NSLog(@"complete");
                    IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingCompleted];
                    break;
                case IEE_MentalCommandTrainingStarted:
                    NSLog(@"start");
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingStarted];
                    break;
                case IEE_MentalCommandTrainingFailed:
                    NSLog(@"fail");
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingFailed];
                    break;
                case IEE_MentalCommandTrainingSucceeded:
                    NSLog(@"success");
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingSuccessed];
                    break;
                case IEE_MentalCommandTrainingRejected:
                    NSLog(@"reject");
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingRejected];
                    break;
                case IEE_MentalCommandTrainingDataErased:
                    NSLog(@"erased");
                    IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingDataErased];
                    break;
                case IEE_MentalCommandSignatureUpdated:
                    NSLog(@"update signature");
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingSignatureUpdated];
                default:
                    break;
            }
        }
    }
}

-(BOOL) setActiveAction : (IEE_MentalCommandAction_t) action
{
    if(!(activeAction & action) && action != MC_NEUTRAL) {
        activeAction = activeAction | action;
        int result = IEE_MentalCommandSetActiveActions(userID, activeAction);
        return result == EDK_OK;
    }
    return true;
}

-(BOOL) setTrainingAction : (IEE_MentalCommandAction_t) action
{
    int result = IEE_MentalCommandSetTrainingAction(userID, (IEE_MentalCommandAction_t)action);
    return result == EDK_OK;
}

-(BOOL) setTrainingControl : (IEE_MentalCommandTrainingControl_t) control
{
    int result = IEE_MentalCommandSetTrainingControl(userID, control);
    return result == EDK_OK;
}

-(BOOL) clearTrainingData : (IEE_MentalCommandAction_t) action
{
    int result1 = IEE_MentalCommandSetTrainingAction(userID, action);
    int result2 = IEE_MentalCommandSetTrainingControl(userID, MC_ERASE);
    return (result1 == EDK_OK) & (result2 == EDK_OK);
}

-(BOOL) isActionTrained : (IEE_MentalCommandAction_t) action
{
    return trainedAction & action;
}

-(int) getTrainingTime {
    unsigned int value = 0;
    IEE_MentalCommandGetTrainingTime(userID, &value);
    return value;
}

-(BOOL) isHeadsetConnected {
    return isConnected;
}
@end
