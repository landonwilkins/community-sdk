//
//  EngineWidget.m
//  FacialExpresison
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <edk/Iedk.h>
@protocol EngineWidgetDelegate <NSObject>

-(void) emoUpdateState : (EmoStateHandle) emoState;
-(void) onHeadsetConnected;
-(void) onHeadsetRemoved;

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

@interface EngineWidget : NSObject

@property(nonatomic, strong) id<EngineWidgetDelegate> delegate;

-(BOOL) setTrainingAction : (IEE_FacialExpressionAlgo_t) action;
-(BOOL) setTrainingControl : (IEE_FacialExpressionTrainingControl_t) control;
-(BOOL) clearTrainingData : (IEE_FacialExpressionAlgo_t) action;
-(int) getTrainingTime;
-(BOOL) isHeadsetConnected;

@end
