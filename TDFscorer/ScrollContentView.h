//
//  ScrollContentView.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/17.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerUIView.h"
#import "AssembleRoundViewController.h"
@interface ScrollContentView : UIView
//@property PlayerUIView *draggedView;
//@property CGRect selectedFrame;
//@property CGPoint selectedPoint;

-(ScrollContentView *) initWithFrame:(CGRect) cgrect assembler:(AssembleRoundViewController *) assembler;
@end
