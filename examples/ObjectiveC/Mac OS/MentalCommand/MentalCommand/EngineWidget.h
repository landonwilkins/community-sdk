//
//  EngineWidget.h
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Edk/Iedk.h>

@protocol EngineWidgetDelegate <NSObject>

-(void) onHeadsetConnected;
-(void) onHeadsetRemoved;
-(void) emoStateUpdate:(IEE_MentalCommandAction_t) action power:(float)power;
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

-(BOOL) setActiveAction : (IEE_MentalCommandAction_t) action;
-(BOOL) setTrainingAction : (IEE_MentalCommandAction_t) action;
-(BOOL) setTrainingControl : (IEE_MentalCommandTrainingControl_t) control;
-(BOOL) clearTrainingData : (IEE_MentalCommandAction_t) action;
-(int) getTrainingTime;
-(BOOL) isHeadsetConnected;
@end
