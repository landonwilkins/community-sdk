//
//  LineGraphView.m
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "LineGraphView.h"
@implementation LineGraphView

#define COUNT 120
#define sampleRate 4

- (id)initWithFrame:(CGRect)frame indexGraph : (int) index
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:frame];
        [self addSubview:self.hostView];
        self.listValue = [[NSMutableArray alloc] initWithCapacity:COUNT];
        indexGraph = index;
        self.countNumber = 120;
        
        [self initPlot];
    }
    return self;
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureGraph];
    [self configureChart];
    [self configureAxes];
    
    currentIndex = 0;
    
    NSTimer *dataTimer = [NSTimer timerWithTimeInterval:1.0 / sampleRate
                                                 target:self
                                               selector:@selector(realtime)
                                               userInfo:nil
                                                repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:dataTimer forMode:NSRunLoopCommonModes];
}

-(void) updateValue : (float) value {
    currentValue = value;
}

-(void) realtime {
    CPTPlot *thePlot   = [self.hostView.hostedGraph plotWithIdentifier:@"Graph"];
    if ( thePlot ) {
        if(self.listValue.count < self.countNumber) {
            [self.listValue addObject:[NSString stringWithFormat:@"%0.2f", currentValue]];
        }
        else {
            NSRange start;
            start.length = self.countNumber - 1;
            start.location = 0;
            
            NSRange end;
            end.length = self.countNumber - 1;
            end.location = 1;
            [self.listValue replaceObjectsInRange:start withObjectsFromArray:self.listValue range:end];
            [self.listValue replaceObjectAtIndex:self.countNumber-1 withObject:[NSString stringWithFormat:@"%0.2f", currentValue]];
        }
    }
    [self.hostView.hostedGraph reloadData];
}

-(void)configureGraph {
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.frame];
    [graph setBackgroundColor:[NSColor clearColor].CGColor];
     self.hostView.hostedGraph = graph;
    
    [graph.plotAreaFrame setPaddingTop:5.0f];
    [graph.plotAreaFrame setPaddingLeft:20.0f];
    [graph.plotAreaFrame setPaddingBottom:5.0f];
}

-(void)configureChart {
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    
    CPTScatterPlot *plotLine = [[CPTScatterPlot alloc] init];
    plotLine.dataSource = self;
    plotLine.identifier = @"Graph";
    [graph addPlot:plotLine toPlotSpace:plotSpace];
    CPTMutableLineStyle  *plotLineStyle = [plotLine.dataLineStyle mutableCopy];
    plotLineStyle.lineWidth = 2;
    switch (indexGraph) {
        case 0:
            plotLineStyle.lineColor = [CPTColor colorWithComponentRed:41.0f/255.0f green:171.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
            break;
        case 1:
            plotLineStyle.lineColor = [CPTColor greenColor];
            break;
        case 2:
            plotLineStyle.lineColor = [CPTColor redColor];
            break;
        case 3:
            plotLineStyle.lineColor = [CPTColor orangeColor];
            break;
        case 4:
            plotLineStyle.lineColor = [CPTColor colorWithComponentRed:0.0f green:165.0f/255.0f blue:0.0f alpha:1.0f];
            break;
        default:
            break;
    }
    plotLine.dataLineStyle = plotLineStyle;
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.0f)];
    [xRange setLocation:CPTDecimalFromDouble(0.0f)];
    [xRange setLength:CPTDecimalFromInt(COUNT)];
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.05f) length:CPTDecimalFromFloat(1.2f)];
    plotSpace.yRange = yRange;
}

-(void) configureAxes {
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 0.5f;
    axisLineStyle.lineColor = [CPTColor grayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Arial";
    axisTextStyle.fontSize = 11.0f;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 2 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.hidden = true;
    
    CPTAxis *y = axisSet.yAxis;
    y.axisLineStyle = axisLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.alternatingBandFills = [NSArray arrayWithObjects:[CPTFill fillWithColor:[CPTColor colorWithComponentRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f]], nil];
    double majorIncrement = 0.5f;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    for (int j = 0; j < 3; j++) {
        CPTAxisLabel *label;
        if(j == 1)
        {
            label = [[CPTAxisLabel alloc] initWithText:@".5" textStyle:axisTextStyle];
        }
        else
            label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%1.0f", majorIncrement * j] textStyle:axisTextStyle];
        NSDecimal location = CPTDecimalFromDouble(majorIncrement * j);
        label.tickLocation = location;
        label.offset = 7.0f;
        if (label) {
            [yLabels addObject:label];
        }
        [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
}

#pragma mark - CPTlistValueSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.listValue.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return [NSNumber numberWithUnsignedInteger:index];
            break;
        case CPTScatterPlotFieldY:
            return  [self.listValue objectAtIndex:index];
            break;
    }
    return 0;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
