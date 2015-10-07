//
//  ViewController.h
//  EmotionalStates
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "ES_EngineWidget.h"
#import "CpLineGraphView.h"
@interface ViewController : UIViewController<ES_EngineWidgetDelegate>
{
    ES_EngineWidget *engineWidget;
    NSMutableArray  *arrayView;
    NSString        *filePath;
    BOOL            isRecording;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btRecord;
- (IBAction)recordData:(UIButton *)sender;

@end

