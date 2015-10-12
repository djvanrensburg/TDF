//
//  RoundsInPlayViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/14.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tournament.h"
#import "GdriveAlertInterface.h"

@interface RoundsInPlayViewController : UIViewController <GdriveAlertInterface>

@property Tournament *tourneyMO;
//@property (nonatomic, retain) GTLServiceDrive *driveService;
@property NSManagedObjectContext *theTournamentContext;
@end
