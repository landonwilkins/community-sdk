//
//  AppDelegate.m
//  EEGLogger
//
//  Created by emotiv on 4/22/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "AppDelegate.h"
#import <edk/Iedk.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    IEE_EngineDisconnect();
    // Insert code here to tear down your application
}

@end
