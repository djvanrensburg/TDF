//
//  RoundViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Round.h"
#import "Tournament.h"
@interface RoundViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (IBAction)unwindToRound:(UIStoryboardSegue *)segue;
@property NSMutableArray *competitionsAR;
@property Round *roundMO;
@property NSNumber *roundNumber;
@property Tournament *tourneyMO;
@property BOOL inUpdateMode;
@property NSManagedObjectContext *theTournamentContext;
@end
