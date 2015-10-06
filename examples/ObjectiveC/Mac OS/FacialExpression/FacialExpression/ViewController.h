//
//  ViewController.h
//  FacialExpression
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
@property (weak) IBOutlet NSTextField *labelStatus;
@property (weak) IBOutlet NSImageView *imageUpperFace;
@property (weak) IBOutlet NSImageView *imageLowerFace;
@property (weak) IBOutlet NSPopUpButton *listAction;
@property (weak) IBOutlet NSProgressIndicator *progressbar;
@property (weak) IBOutlet NSButton *buttonTraining;

- (IBAction)chooseAction:(NSPopUpButton *)sender;
- (IBAction)trainingAction:(id)sender;
- (IBAction)clearAction:(id)sender;

@end

