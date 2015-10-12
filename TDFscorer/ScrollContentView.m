//
//  ScrollContentView.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/17.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import "ScrollContentView.h"
#import "AssembleRoundViewController.h"

@interface ScrollContentView ()
@property AssembleRoundViewController *assembler;
@end

@implementation ScrollContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(ScrollContentView *) initWithFrame:(CGRect) cgrect assembler:(AssembleRoundViewController *) assembler{
    self.assembler = assembler;
    return [super initWithFrame:cgrect];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches ] anyObject];
    //check if a player isn't already touched
//    if (self.assembler.draggedView != nil) {
//        <#statements#>
//    }
    self.assembler.draggedView = nil;
    for (UIView *playerView in self.subviews) {
        if (touch.view == playerView && [touch.view isKindOfClass:[PlayerUIView class]]) {
            PlayerUIView *touchedPlayer = (PlayerUIView *)playerView;
            self.assembler.draggedView = touchedPlayer;
            self.assembler.selectedFrame = self.assembler.draggedView.frame;
            self.assembler.selectedPoint = self.assembler.draggedView.center;
            [playerView removeFromSuperview];
            break;
        }
    }
    for (UIView *subv in self.assembler.draggedView.subviews) {
        if (subv.tag == 1) {
            subv.layer.borderColor = [UIColor blueColor].CGColor;
            break;
        }
    }
    [self.assembler.view addSubview:self.assembler.draggedView];
    [self.assembler touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}
@end
