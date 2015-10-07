//
//  GraphView.h
//  emotivExample
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2014 EmotivLifeSciences. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CpLineGraphView.h"

@interface GraphView : UIView
{
    CpLineGraphView *graph;
    int index;
}
-(id) initWithFrame:(CGRect)frame index:(int)number;
-(void) updateValue : (float) value;
@end
