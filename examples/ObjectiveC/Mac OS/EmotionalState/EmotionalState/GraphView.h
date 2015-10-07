//
//  GraphView.h
//  EmotionalState
//
//  Created by emotiv on 4/23/15.
//  Copyright (c) 2015 emotiv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LineGraphView.h"

@interface GraphView : NSView
{
    LineGraphView *graph;
    int index;
}
-(id) initWithFrame:(CGRect)frame index:(int)number;
-(void) updateValue : (float) value;
@end
