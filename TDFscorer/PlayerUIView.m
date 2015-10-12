//
//  PlayerUIView.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/17.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "PlayerUIView.h"

@implementation PlayerUIView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@synthesize player;
@synthesize groupNum;
@synthesize playerNum;

- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
//    if (self) {
//        // setup the initial properties of the view
//        ...
//    }
    return self;
}

//- (void)dealloc {
//    // Release a retained UIColor object
////    [color release];
//    
//    // Call the inherited implementation
//    [super dealloc];
//}
@end
