//
//  PlayerTeamSelectViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/30.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerInTourney.h"
@interface PlayerTeamSelectViewController : UIViewController
@property NSArray *teamsAR;
@property PlayerInTourney *playerMO;
@property UITableView *playerTable;
@end
