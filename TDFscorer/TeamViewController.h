//
//  TeamViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/22.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface TeamViewController : UIViewController

@property Team *teamMO;
@property NSManagedObjectContext *theTournamentContext;
@end
