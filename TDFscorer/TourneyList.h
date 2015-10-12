//
//  TourneyList.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GdriveAlertInterface.h"
#import "Tournament.h"
@interface TourneyList : UITableViewController <GdriveAlertInterface>

- (IBAction)unwindToTourneyList:(UIStoryboardSegue *)segue;
//@property (strong, nonatomic) IBOutlet UITableView *tableOfTourneysRef;
@property BOOL toGames;
@property Tournament *directImmportedTourney;
@property NSManagedObjectContext *theTournamentContext;
@property NSMutableArray *tourneys;
@end
