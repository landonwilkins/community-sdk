//
//  GraphView.m
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

-(id) initWithFrame:(CGRect)frame index:(int)number
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSArray *arrayTitle = [NSArray arrayWithObjects:@"Engagement", @"Relax", @"Stress", @"Instantaneous Excitement", @"Interest", nil];
        
        graph = [[LineGraphView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width + 20, self.frame.size.height-5) indexGraph:number];
        [self addSubview:graph];
        
        NSView *viewBanner = [[NSView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30)];
        
        NSTextField *label = [[NSTextField alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
        label.stringValue = [arrayTitle objectAtIndex:number];
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [viewBanner addSubview:label];
        
        [self addSubview:viewBanner];
        
        index = number;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    switch (index) {
        case 0:
            CGContextSetRGBFillColor(context, 41.0f/255.0f,171.0f/255.0f,247.0f/255.0f,1.0f);
            break;
        case 1:
            CGContextSetRGBFillColor(context, 0.0f,1.0f,0.0f,1.0f);
            break;
        case 2:
            CGContextSetRGBFillColor(context, 1.0f,0.0f,0.0f,1.0f);
            break;
        case 3:
            CGContextSetRGBFillColor(context, 1.0f,153.0f/255.0f,0.0f,1.0f);
            break;
        case 4:
            CGContextSetRGBFillColor(context, 0.0f,165.0f/255.0f,0.0f,1.0f);
            break;
        default:
            break;
    }
    CGContextFillRect(context, NSRectToCGRect(dirtyRect));
    // Drawing code here.
}

-(void) updateValue : (float) value {
    [graph updateValue:value];
}
@end
