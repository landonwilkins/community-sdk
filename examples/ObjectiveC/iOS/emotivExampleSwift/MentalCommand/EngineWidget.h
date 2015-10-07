//
//  EngineWidget.h
//  emotivExampleSwift
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MentalControl_enum
{
    Mental_None,
    Mental_Start,
    Mental_Accept,
    Mental_Reject,
    Mental_Erase,
    Mental_Reset
} MentalControl_t;

typedef enum MentalAction_enum
{
    Mental_Neutral = 0x0001,
    Mental_Push = 0x0002,
    Mental_Pull = 0x0004,
    Mental_Lift = 0x0008,
    Mental_Drop = 0x0010,
    Mental_Left = 0x0020,
    Mental_Right = 0x0040
} MentalAction_t;

@protocol EngineWidgetDelegate <NSObject>

-(void) emoStateUpdate : (MentalAction_t) currentAction power : (float) currentPower;
@optional
-(void) onMentalCommandTrainingStarted;
-(void) onMentalCommandTrainingSuccessed;
-(void) onMentalCommandTrainingFailed;
-(void) onMentalCommandTrainingCompleted;
-(void) onMentalCommandTrainingRejected;
-(void) onMentalCommandTrainingDataErased;
-(void) onMentalCommandTrainingDataReset;
-(void) onMentalCommandTrainingSignatureUpdated;
@end



@interface EngineWidget : NSObject

@property(nonatomic, strong) id<EngineWidgetDelegate> delegate;

-(void) setActiveAction : (MentalAction_t) action;
-(void) setTrainingAction : (MentalAction_t) action;
-(void) setTrainingControl : (MentalControl_t) control;
-(void) clearTrainingData : (MentalAction_t) action;
-(int) getSkillRating : (MentalAction_t) action;
-(BOOL) isActionTrained : (MentalAction_t) action;
-(BOOL) isHeadsetConnected;
@end
