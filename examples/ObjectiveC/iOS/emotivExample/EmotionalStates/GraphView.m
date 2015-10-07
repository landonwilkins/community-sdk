//
//  GraphView.m
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

-(id) initWithFrame:(CGRect)frame index:(int)number
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSArray *arrayTitle = [NSArray arrayWithObjects:@"Engagement", @"Relax", @"Longterm Excitement", @"Instantaneous Excitement", nil];
        
        graph = [[CpLineGraphView alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width + 20, self.frame.size.height+10) indexGraph:number];
        [self addSubview:graph];
        
        UIView *viewBanner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        switch (number) {
            case 0:
                viewBanner.backgroundColor = [UIColor colorWithRed:41.0f/255.0f green:171.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
                break;
            case 1:
                viewBanner.backgroundColor = [UIColor greenColor];
                break;
            case 2:
                viewBanner.backgroundColor = [UIColor redColor];
                break;
            case 3:
                viewBanner.backgroundColor = [UIColor orangeColor];
                break;
            default:
                break;
        }
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        [label setText:[arrayTitle objectAtIndex:number]];
        [label setTextColor:[UIColor whiteColor]];
        [viewBanner addSubview:label];
        
        [self addSubview:viewBanner];
        
        index = number;
    }
    return self;
}

-(void) layoutSubviews {

}

-(void) updateValue : (float) value {
    [graph updateValue:value];
}

@end
