//
//  LeaderboardTableViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Tournament.h"
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GdriveAlertInterface.h"
@interface LeaderboardTableViewController : UITableViewController <GdriveAlertInterface>

@property Tournament *tourneyMO;
@end
