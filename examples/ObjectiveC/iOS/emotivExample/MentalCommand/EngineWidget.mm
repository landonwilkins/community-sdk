//
//  EngineWidget.m
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "EngineWidget.h"
#import <edk_ios/Iedk.h>

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

-(void) connectEmoComposer
{
    IEE_EngineRemoteConnect("127.0.0.1", 1726);
}

-(void) getNextEvent {
    int counter_insight = IEE_GetNumberDeviceInsight();
    if(counter_insight > 0){
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
            IEE_MentalCommandAction_t action = IS_MentalCommandGetCurrentAction(eState);
            float power = IS_MentalCommandGetCurrentActionPower(eState);
            if(self.delegate)
                [self.delegate emoStateUpdate:(MentalAction_t)action power:power];
        }
        if(eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            userAdded = true;
            IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
            IEE_MentalCommandGetActiveActions(userID, &activeAction);
        }
        if(eventType == IEE_UserRemoved){
            NSLog(@"user remove");
            isConnected = false;
            userAdded = false;
        }
        if(eventType == IEE_MentalCommandEvent) {
            IEE_MentalCommandEvent_t mcevent = IEE_MentalCommandEventGetType(eEvent);
            switch (mcevent) {
                case IEE_MentalCommandTrainingCompleted:
                    IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingCompleted];
                    NSLog(@"complete");
                    break;
                case IEE_MentalCommandTrainingStarted:
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingStarted];
                    NSLog(@"start");
                    break;
                case IEE_MentalCommandTrainingFailed:
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingFailed];
                    NSLog(@"fail");
                    break;
                case IEE_MentalCommandTrainingSucceeded:
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingSuccessed];
                    NSLog(@"success");
                    break;
                case IEE_MentalCommandTrainingRejected:
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingRejected];
                    NSLog(@"reject");
                    break;
                case IEE_MentalCommandTrainingDataErased:
                    IEE_MentalCommandGetTrainedSignatureActions(userID, &trainedAction);
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingDataErased];
                    NSLog(@"erased");
                    break;
                case IEE_MentalCommandSignatureUpdated:
                    if(self.delegate)
                        [self.delegate onMentalCommandTrainingSignatureUpdated];
                    NSLog(@"update signature");
                default:
                    break;
            }
        }
    }
}

-(void) setActiveAction : (MentalAction_t) action
{
    if(!(activeAction & action) && action != Mental_Neutral) {
        activeAction = activeAction | action;
        IEE_MentalCommandSetActiveActions(userID, activeAction);
    }
}

-(void) setTrainingAction : (MentalAction_t) action
{
    IEE_MentalCommandSetTrainingAction(userID, (IEE_MentalCommandAction_t)action);
}

-(void) setTrainingControl : (MentalControl_t) control
{
    IEE_MentalCommandSetTrainingControl(userID, (IEE_MentalCommandTrainingControl_t)control);
}

-(void) clearTrainingData : (MentalAction_t) action
{
    IEE_MentalCommandSetTrainingAction(userID, (IEE_MentalCommandAction_t) action);
    IEE_MentalCommandSetTrainingControl(userID, (IEE_MentalCommandTrainingControl_t)MC_ERASE);
}

-(int) getSkillRating : (MentalAction_t) action
{
    float skillRating = 0.0f;
    IEE_MentalCommandGetActionSkillRating(userID, (IEE_MentalCommandAction_t)action, &skillRating);
    return (int)(skillRating * 100);
}

-(BOOL) isActionTrained : (MentalAction_t) action
{
    return trainedAction & action;
}

-(BOOL) isHeadsetConnected {
    return userAdded;
}
@end
