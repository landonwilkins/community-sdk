//
//  ViewController.m
//  MentalCommand
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "ViewController.h"
#import <edk/Iedk.h>

IEE_MentalCommandAction_t currentAction = MC_NEUTRAL;
float currentPower = 0;
NSPoint startPoint;
CGSize startSize;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    engineWidget = [[EngineWidget alloc] init];
    engineWidget.delegate = self;
    isTraining = false;
    
    dictionaryAction = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:MC_NEUTRAL], @"Neutral", [NSNumber numberWithInt:MC_PUSH], @"Push", [NSNumber numberWithInt:MC_PULL], @"Pull", [NSNumber numberWithInt:MC_LEFT], @"Left", [NSNumber numberWithInt:MC_RIGHT], @"Right", [NSNumber numberWithInt:MC_LIFT], @"Lift", [NSNumber numberWithInt:MC_DROP], @"Drop", nil];
    arrayAction = [NSArray arrayWithObjects:@"", @"Neutral", @"Pull", @"Push", @"Left", @"Right", @"Lift", @"Drop", nil];
    [self.listAction removeAllItems];
    [self.listAction addItemsWithTitles:arrayAction];
    self.listAction.title = @"Neutral";
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCubePosition) userInfo:nil repeats:YES];
    
    
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear {
    startPoint.x = self.imageCube.frame.origin.x + (self.imageCube.frame.size.width) / 2;
    startPoint.y = self.imageCube.frame.origin.y + (self.imageCube.frame.size.height) / 2;
    startSize = self.imageCube.frame.size;
    
    [self.containView setWantsLayer:YES];
    [self.containView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    [self.powerView setWantsLayer:YES];
    [self.powerView.layer setBackgroundColor:[[NSColor grayColor] CGColor]];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark IBAction Function

- (IBAction)trainingAction:(id)sender {
    if([engineWidget isHeadsetConnected]) {
        
        NSNumber *action = [dictionaryAction objectForKey:self.listAction.title];
        
        if(!isTraining) {
            if(action.integerValue != MC_NEUTRAL) {
                [engineWidget setActiveAction:(IEE_MentalCommandAction_t)action.integerValue];
            }
            if(![engineWidget setTrainingAction:(IEE_MentalCommandAction_t)action.integerValue]){
                NSLog(@"error");
            }
            if(![engineWidget setTrainingControl:MC_START]){
                NSLog(@"error");
            }
            isTraining = true;
            self.buttonTraining.title = @"Abort";
        }
        else {
            [engineWidget setTrainingControl:MC_RESET];
        }
    }
    else {
        [self showWarningHeadset];
    }
}

- (IBAction)clearAction:(id)sender {
     if([engineWidget isHeadsetConnected]) {
         NSNumber *action = [dictionaryAction objectForKey:self.listAction.title];
         [engineWidget clearTrainingData:(IEE_MentalCommandAction_t)action.integerValue];
     }
     else {
         [self showWarningHeadset];
     }
}

- (IBAction)chooseAction:(NSPopUpButton *)sender {
    sender.title = [arrayAction objectAtIndex:sender.indexOfSelectedItem];
}

-(void) showWarningHeadset {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:@"Connect headset first."];
    [alert runModal];
}

-(void) updateCubePosition {
    
    float range = currentPower * 4;
    
    float centerX = self.imageCube.frame.origin.x + (self.imageCube.frame.size.width) / 2;
    float centerY = self.imageCube.frame.origin.y + (self.imageCube.frame.size.height) / 2;
    
    //move cube to left or right direction
    if((currentAction == MC_LEFT || currentAction == MC_RIGHT) && range > 0)
    {
        centerX = currentAction == MC_LEFT ? MAX(startPoint.x - 100, centerX - range) : MIN(startPoint.x + 100, centerX + range);
    }
    else if(centerX != startPoint.x)
    {
        centerX = centerX > startPoint.x ? MAX(startPoint.x, centerX - 4) : MIN(startPoint.x, centerX + 4);
    }
    
    //move cube to up or down direction
    if ((currentAction == MC_LIFT || currentAction == MC_DROP) && range > 0)
    {
        centerY = currentAction == MC_LIFT ? MIN(startPoint.y + 70, centerY + range) : MAX(startPoint.y - 70, centerY - range);
    }
    else if(centerY != startPoint.y)
    {
        centerY = centerY > startPoint.y ? MAX(startPoint.y, centerY - 4) : MIN(startPoint.y, centerY + 4);
    }

    //move cube to forward or backward direction
    if ((currentAction == MC_PULL || currentAction == MC_PUSH) && range > 0)
    {
        NSSize unitSize;
        unitSize.width = currentAction == MC_PUSH ? MAX(startSize.width / 5, self.imageCube.frame.size.width / 1.1) : MIN(startSize.width * 2.5, self.imageCube.frame.size.width / 0.9);
        unitSize.height = currentAction == MC_PUSH ? MAX(startSize.height / 5, self.imageCube.frame.size.height / 1.1) : MIN(startSize.height * 2.5, self.imageCube.frame.size.height / 0.9);
        [self.imageCube setFrameSize:unitSize];
    }
    else if (self.imageCube.frame.size.width != startSize.width)
    {
        NSSize unitSize;
        unitSize.width = self.imageCube.frame.size.width > startSize.width ? MAX(startSize.width, self.imageCube.frame.size.width / 1.1) : MIN(startSize.width, self.imageCube.frame.size.width / 0.9);
        unitSize.height = self.imageCube.frame.size.height > startSize.height ? MAX(startSize.height, self.imageCube.frame.size.height / 1.1) : MIN(startSize.height, self.imageCube.frame.size.height / 0.9);
        [self.imageCube setFrameSize:unitSize];
    }

    NSPoint point;
    point.x = centerX - self.imageCube.frame.size.width/2;
    point.y = centerY - self.imageCube.frame.size.height/2;

    [self.imageCube setFrameOrigin:point];
}

#pragma mark EmoEngineWidget Delegate

-(void) onHeadsetConnected {
    self.labelStatus.stringValue = @"Connected";
}

-(void) onHeadsetRemoved {
    self.labelStatus.stringValue = @"Disconnected";
}

-(void) emoStateUpdate:(IEE_MentalCommandAction_t) action power:(float)power {
    currentAction = action;
    currentPower = power;
    NSRect rect = self.powerView.frame;
    rect.size.height = currentPower * self.containView.frame.size.height;
    self.powerView.frame = rect;
}

-(void) onMentalCommandTrainingStarted {
    self.progressbar.doubleValue = 0;
    self.progressbar.hidden = false;
    self.progressbar.maxValue = [engineWidget getTrainingTime];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

-(void) onMentalCommandTrainingSuccessed {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Accept"];
    [alert addButtonWithTitle:@"Reject"];
    [alert setMessageText:@"Training Successed"];
    [alert setInformativeText:@"Do you want to accept this training?"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [engineWidget setTrainingControl:MC_ACCEPT];
    }
    else {
        [engineWidget setTrainingControl:MC_REJECT];
    }
}

-(void) onMentalCommandTrainingCompleted {
    [self updateUI];

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Training Completed"];
    [alert setInformativeText:@"Action was trained completed."];
    [alert runModal];
}

-(void) onMentalCommandTrainingDataErased {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Erase Completed"];
    [alert setInformativeText:@"Action was erased completed."];
    [alert runModal];
}

-(void) onMentalCommandTrainingFailed {
    [self updateUI];
}

-(void) onMentalCommandTrainingSignatureUpdated {
    [self updateUI];
}

-(void) onMentalCommandTrainingRejected {
    [self updateUI];
}

-(void) onMentalCommandTrainingDataReset {
    [self updateUI];
}

#pragma mark Update User Interface Function

-(void) updateUI {
    if(timer)
        [timer invalidate];
    self.progressbar.hidden = true;
    isTraining = false;
    self.buttonTraining.title = @"Training";
}

-(void) updateProgress {
    [self.progressbar setDoubleValue:(self.progressbar.doubleValue + 100)];
}
@end
