//
//  ViewController.h
//  MentalCommand
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EngineWidget.h"

@interface ViewController : NSViewController<EngineWidgetDelegate>
{
    NSDictionary    *dictionaryAction;
    NSArray         *arrayAction;
    EngineWidget    *engineWidget;
    NSTimer         *timer;
    BOOL            isTraining;
}
@property (weak) IBOutlet NSPopUpButton *listAction;
@property (weak) IBOutlet NSButton *buttonTraining;
@property (weak) IBOutlet NSButton *buttonClear;
@property (weak) IBOutlet NSImageView *imageCube;
@property (weak) IBOutlet NSProgressIndicator *progressbar;
@property (weak) IBOutlet NSView *containView;
@property (weak) IBOutlet NSView *powerView;
@property (weak) IBOutlet NSTextField *labelStatus;

- (IBAction)trainingAction:(id)sender;
- (IBAction)clearAction:(id)sender;
- (IBAction)chooseAction:(NSPopUpButton *)sender;
@end

