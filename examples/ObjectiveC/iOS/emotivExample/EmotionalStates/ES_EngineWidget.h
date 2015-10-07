//
//  FE_EngineWidget.h
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ES_EngineWidgetDelegate <NSObject>

-(void) emoStateUpdate : (NSArray *) arrayScore;

@end

@interface ES_EngineWidget : NSObject

@property(nonatomic, strong) id<ES_EngineWidgetDelegate> delegate;

-(BOOL) isHeadsetConnected;

@end
