//
//  ViewController.m
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

/*This example just work with Version SDK Premium*/


#import "ViewController.h"
#import <edk/Iedk.h>

@implementation ViewController

EmoEngineEventHandle eEvent;
EmoStateHandle eState;
NSMutableArray *arrayView;
BOOL isConnected = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrayView = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 5; i++)
    {
        GraphView *view = [[GraphView alloc] initWithFrame:CGRectMake(0, 50 + 120*i, self.view.frame.size.width, 120) index:i];
        [self.view addSubview:view];
        [arrayView addObject:view];
    }
    eEvent	= IEE_EmoEngineEventCreate();
    eState	= IEE_EmoStateCreate();
    isRecording = false;
    
    IEE_EmoInitDevice();
    
    if( IEE_EngineConnect() != EDK_OK ) {
        
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getNextEvent) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

-(void) getNextEvent {
    int numberDevice = IEE_GetNumberDeviceInsight();
    if(numberDevice > 0 && !isConnected) {
        IEE_EmoConnectDevice(0);
    }
    int state = IEE_EngineGetNextEvent(eEvent);
    unsigned int userID = 0;
    
    if (state == EDK_OK)
    {
        
        IEE_Event_t eventType = IEE_EmoEngineEventGetType(eEvent);
        IEE_EmoEngineEventGetUserId(eEvent, &userID);
        
        // Log the EmoState if it has been updated
        if (eventType == IEE_UserAdded)
        {
            NSLog(@"User Added");
            isConnected = true;
        }
        else if (eventType == IEE_UserRemoved)
        {
            NSLog(@"User Removed");
            isConnected = false;
        }
        else if (eventType == IEE_EmoStateUpdated)
        {
            IEE_EmoEngineEventGetEmoState(eEvent, eState);
            NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:IS_PerformanceMetricGetEngagementBoredomScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetRelaxationScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetStressScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetInstantaneousExcitementScore(eState)], [NSNumber numberWithFloat:IS_PerformanceMetricGetInterestScore(eState)], nil];
            
            [[arrayView objectAtIndex:0] updateValue:IS_PerformanceMetricGetEngagementBoredomScore(eState)];
            [[arrayView objectAtIndex:1] updateValue:IS_PerformanceMetricGetRelaxationScore(eState)];
            [[arrayView objectAtIndex:2] updateValue:IS_PerformanceMetricGetStressScore(eState)];
            [[arrayView objectAtIndex:3] updateValue:IS_PerformanceMetricGetInstantaneousExcitementScore(eState)];
            [[arrayView objectAtIndex:4] updateValue:IS_PerformanceMetricGetInterestScore(eState)];
            
            [self writeData:array];

        }
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)clickButton:(id)sender {
    isRecording = !isRecording;
    if(isRecording) {
        NSString* fileName = @"EmoStateLogger.csv";
        NSString* createFile = @"";
        [createFile writeToFile:fileName atomically:YES encoding:NSUnicodeStringEncoding error:nil];
        
        NSArray *arrayTitle = [NSArray arrayWithObjects:@"Engagement", @"Relax", @"Stress", @"Instantaneous Excitement", @"Interest", nil];
        [self writeData:arrayTitle];
        
        self.buttonRecord.title = @"Stop record";
    }
    else
    {
        self.buttonRecord.title = @"Record data";
    }
}

-(void) writeData : (NSArray *) array
{
    if(isRecording)
    {
        NSString *data = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
        for (int i = 1; i < [array count]; i++) {
            @autoreleasepool {
                data = [data stringByAppendingFormat:@", %@", [array objectAtIndex:i]];
            }
        }
        data = [data stringByAppendingFormat:@"\n"];
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:@"EmoStateLogger.csv"];
        [fh seekToEndOfFile];
        [fh writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [fh closeFile];
    }
}
@end
