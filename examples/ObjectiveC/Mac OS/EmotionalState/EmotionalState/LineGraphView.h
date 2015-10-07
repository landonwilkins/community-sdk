//
//  LineGraphView.h
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface LineGraphView : NSView<CPTPlotDataSource>
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
