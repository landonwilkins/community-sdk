//
//  CpLineGraphView.h
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CpLineGraphView : UIView<CPTPlotDataSource>
{
    int indexGraph;
    int currentIndex;
    float currentValue;
}
@property (nonatomic, strong)NSMutableArray *listValue;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic) int countNumber;

- (id)initWithFrame:(CGRect)frame indexGraph : (int) index;
-(void) updateValue : (float) value;
@end
