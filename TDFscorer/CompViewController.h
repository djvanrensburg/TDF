//
//  CompViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Competition.h"
#import "Round.h"
#import "Tournament.h"
@interface CompViewController : UIViewController
//@property NSManagedObject *compMO;
@property Competition *compMO;
@property Tournament *tourneyMO;

@property NSManagedObjectContext *theTournamentContext;
@end
