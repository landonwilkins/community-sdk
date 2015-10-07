//
//  ViewController.h
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GraphView.h"

@interface ViewController : NSViewController
{
    Boolean isRecording;
}
@property (weak) IBOutlet NSButton *buttonRecord;
- (IBAction)clickButton:(id)sender;

@end

