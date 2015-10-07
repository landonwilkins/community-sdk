//
//  ViewController.m
//  EmotionalStates
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "EsViewController.h"

@interface ViewController ()

@end

CpLineGraphView *cp;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    engineWidget = [[ES_EngineWidget alloc] init];
    [engineWidget setDelegate:self];
    
    arrayView = [[NSMutableArray alloc] initWithCapacity:4];
    
    for(int i = 0; i < 4; i++)
    {
        GraphView *view = [[GraphView alloc] initWithFrame:CGRectMake(0, 0 + 200*i, self.view.frame.size.width, 200) index:i];
        [self.scrollView addSubview:view];        
        [arrayView addObject:view];
    }

    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewDidAppear:(BOOL)animated {
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 800)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) emoStateUpdate : (NSArray *) arrayScore
{
    for(int i = 0; i < arrayScore.count; i++)
    {
        GraphView *view = [arrayView objectAtIndex:i];
        [view updateValue:[[arrayScore objectAtIndex:i] floatValue]];
    }
    [self writeData:arrayScore];
}
- (IBAction)recordData:(UIButton *)sender {
    if(!isRecording)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        filePath = [documentsDir stringByAppendingPathComponent:@"affectiv.csv"];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        
        [self.btRecord setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else
    {
        [self.btRecord setTitle:@"Record" forState:UIControlStateNormal];
    }
    isRecording = !isRecording;

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
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fh seekToEndOfFile];
        [fh writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
        [fh closeFile];
    }
}
@end
