//
//  FE_EngineWidget.h
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum FacialControl_enum
{
    Facial_None = 0,
    Facial_Start,
    Facial_Accept,
    Facial_Reject,
    Facial_Erase,
    Facial_Reset
} FacialControl_t;

typedef enum FacialAction_enum
{
    Facial_Neutral          = 0x0001,
    Facial_Blink			= 0x0002,
    Facial_Wink_Left		= 0x0004,
    Facial_Wink_Right		= 0x0008,
    Facial_Suprise			= 0x0020,
    Facial_Frown			= 0x0040,
    Facial_Smile			= 0x0080,
    Facial_Clench			= 0x0100,
} FacialAction_t;

typedef enum MentalAction_enum
{
    Mental_Neutral = 0x0001,
    Mental_Push = 0x0002,
    Mental_Pull = 0x0004,
    Mental_Lift = 0x0008,
    Mental_Drop = 0x0010,
    Mental_Left = 0x0020,
    Mental_Right = 0x0040,
    Mental_Dissappear = 0x2000
} MentalAction_t;

@protocol FE_EngineWidgetDelegate <NSObject>

-(void) updateLowerFaceAction : (NSString *) currentAction power : (float) power;

@optional
-(void) onFacialExpressionTrainingStarted;
-(void) onFacialExpressionTrainingSuccessed;
-(void) onFacialExpressionTrainingFailed;
-(void) onFacialExpressionTrainingCompleted;
-(void) onFacialExpressionTrainingRejected;
-(void) onFacialExpressionTrainingDataErased;
-(void) onFacialExpressionTrainingDataReset;
-(void) onFacialExpressionTrainingSignatureUpdated;
@end

@interface FE_EngineWidget : NSObject

@property(nonatomic, strong) id<FE_EngineWidgetDelegate> delegate;

-(void) setTrainingAction : (NSString *) action;
-(void) setTrainingControl : (FacialControl_t) control;
-(void) clearTrainingData : (NSString *) action;
-(BOOL) isActionTrained : (NSString *) action;
-(void) setSensitivity : (NSString *) action value : (int) value;
-(int) getSensitivity : (NSString *) action;
-(BOOL) isHeadsetConnected;

@end
