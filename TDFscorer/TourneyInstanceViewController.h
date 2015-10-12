//
//  TourneyInstanceViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tournament.h"
@interface TourneyInstanceViewController : UIViewController
- (IBAction)unwindToTourneyInst:(UIStoryboardSegue *)segue;
@property NSMutableArray *roundsAR;
@property NSArray *teamsAR;

@property Tournament *tournamentMO;
@property BOOL isInUpdate;
@property NSManagedObjectContext *theTournamentContext;

@end
