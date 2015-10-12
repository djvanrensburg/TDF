//
//  ScoringUISlider.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/25.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hole.h"
#import "PlayerInGroup.h"
@interface ScoringUISlider : UISlider

@property (nonatomic, retain) Hole *holeMO;
@property (nonatomic, retain) PlayerInGroup *playerMO;
@end
