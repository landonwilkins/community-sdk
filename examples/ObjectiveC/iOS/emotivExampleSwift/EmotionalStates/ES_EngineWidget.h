//
//  ES_EngineWidget.h
//  emotivExampleSwift
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ES_EngineWidgetDelegate <NSObject>

-(void) emoStateUpdate : (NSArray *) arrayScore;

@end

@interface ES_EngineWidget : NSObject

@property(nonatomic, strong) id<ES_EngineWidgetDelegate> delegate;

-(BOOL) isHeadsetConnected;

@end
