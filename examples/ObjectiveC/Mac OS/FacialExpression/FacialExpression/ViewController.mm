//
//  ViewController.m
//  FacialExpression
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    engineWidget = [[EngineWidget alloc] init];
    engineWidget.delegate = self;
    isTraining = false;
    dictionaryAction = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:FE_NEUTRAL], @"Neutral", [NSNumber numberWithInt:FE_SMILE], @"Smile", [NSNumber numberWithInt:FE_CLENCH], @"Clench", [NSNumber numberWithInt:FE_FROWN], @"Frown", [NSNumber numberWithInt:FE_SURPRISE], @"Surprise", nil];
    arrayAction = [NSArray arrayWithObjects:@"", @"Neutral", @"Smile", @"Clench", @"Frown", @"Surprise", nil];
    [self.listAction removeAllItems];
    [self.listAction addItemsWithTitles:arrayAction];
    self.listAction.title = @"Neutral";
    self.labelStatus.stringValue = @"Disconnect";
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark IBAction Function

- (IBAction)chooseAction:(NSPopUpButton *)sender {
    sender.title = [arrayAction objectAtIndex:sender.indexOfSelectedItem];
}

- (IBAction)trainingAction:(id)sender {
    if([engineWidget isHeadsetConnected]) {
        
        NSNumber *action = [dictionaryAction objectForKey:self.listAction.title];
        
        if(!isTraining) {
            if(![engineWidget setTrainingAction:(IEE_FacialExpressionAlgo_t)action.integerValue]){
                NSLog(@"error");
            }
            if(![engineWidget setTrainingControl:FE_START]){
                NSLog(@"error");
            }
            isTraining = true;
            self.buttonTraining.title = @"Abort";
        }
        else {
            [engineWidget setTrainingControl:FE_RESET];
        }
    }
    else {
        [self showWarningHeadset];
    }
}

- (IBAction)clearAction:(id)sender {
    if([engineWidget isHeadsetConnected]) {
        NSNumber *action = [dictionaryAction objectForKey:self.listAction.title];
        [engineWidget clearTrainingData:(IEE_FacialExpressionAlgo_t)action.integerValue];
    }
    else {
        [self showWarningHeadset];
    }
}


#pragma mark EmoEngineWidget Delegate
-(void) onHeadsetConnected {
    self.labelStatus.stringValue = @"Connected";
}

-(void) onHeadsetRemoved {
    self.labelStatus.stringValue = @"Disconnected";
}

-(void) emoUpdateState:(EmoStateHandle)emoState {

    if(IS_FacialExpressionGetUpperFaceAction(emoState) == FE_FROWN)
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_eyes_furrow"]];
    else if(IS_FacialExpressionGetUpperFaceAction(emoState) == FE_SURPRISE)
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_supprise_top"]];
    else
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_upperface"]];
    
    if(IS_FacialExpressionIsBlink(emoState))
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_eyes_blink"]];
    else if (IS_FacialExpressionIsLeftWink(emoState))
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_eyes_winkLeft"]];
    else if (IS_FacialExpressionIsRightWink(emoState))
        [self.imageUpperFace setImage:[NSImage imageNamed:@"BG_eyes_winkRight"]];
    
    if(IS_FacialExpressionGetLowerFaceAction(emoState) == FE_SMILE) {
        if(IS_FacialExpressionGetLowerFaceActionPower(emoState) > 0.7)
            [self.imageLowerFace setImage:[NSImage imageNamed:@"BG_mouth_bigsmile"]];
        else
            [self.imageLowerFace setImage:[NSImage imageNamed:@"BG_mouth_smile"]];
    }
    else if(IS_FacialExpressionGetUpperFaceAction(emoState) == FE_CLENCH)
        [self.imageLowerFace setImage:[NSImage imageNamed:@"BG_mouth_clench"]];
        
    else
        [self.imageLowerFace setImage:[NSImage imageNamed:@"BG_midface"]];
}

-(void) onFacialExpressionTrainingStarted {
    self.progressbar.doubleValue = 0;
    self.progressbar.hidden = false;
    self.progressbar.maxValue = [engineWidget getTrainingTime];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

-(void) onFacialExpressionTrainingSuccessed {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Accept"];
    [alert addButtonWithTitle:@"Reject"];
    [alert setMessageText:@"Training Successed"];
    [alert setInformativeText:@"Do you want to accept this training?"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [engineWidget setTrainingControl:FE_ACCEPT];
    }
    else {
        [engineWidget setTrainingControl:FE_REJECT];
    }
}

-(void) onFacialExpressionTrainingCompleted {
   [self updateUI];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Training Completed"];
    [alert setInformativeText:@"Action was trained completed."];
    [alert runModal];
}

-(void) onFacialExpressionTrainingDataErased {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Erase Completed"];
    [alert setInformativeText:@"Action was erased completed."];
    [alert runModal];
}

-(void) onFacialExpressionTrainingFailed {
    [self updateUI];
}

-(void) onFacialExpressionTrainingSignatureUpdated {
    
}

-(void) onFacialExpressionTrainingRejected {
    [self updateUI];
}

-(void) onFacialExpressionTrainingDataReset {
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

-(void) showWarningHeadset {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:@"Connect headset first."];
    [alert runModal];
}
@end
