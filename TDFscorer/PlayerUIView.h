//
//  PlayerUIView.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/17.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerInTourney.h"

@interface PlayerUIView : UIView{
    PlayerInTourney * player;
}

@property (nonatomic, retain) PlayerInTourney * player;
@property int groupNum;
@property int playerNum;

- (id)initWithFrame:(CGRect)aRect;

@end
