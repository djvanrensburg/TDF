//
//  ScoringViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scorecard.h"
#import "Round.h"


@interface ScoringViewController : UIViewController

@property Round *roundMO;
//@property (nonatomic, retain) GTLServiceDrive *driveService;
@property BOOL internetPlay;
@property NSManagedObjectContext *theTournamentContext;
@end
