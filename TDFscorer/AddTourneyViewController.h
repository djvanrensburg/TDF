//
//  AddTourneyViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tournament.h"
//#import "GdriveAlertInterface.h"

@interface AddTourneyViewController : UIViewController //<GdriveAlertInterface>
//@property long indexOfTourney;
//@property (nonatomic, retain) GTLServiceDrive *driveService;
@property Tournament *tournamentMO;
@property NSManagedObjectContext *theTournamentContext;
@end
