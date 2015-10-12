//
//  AssembleRoundViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/14.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tournament.h"
#import "Round.h"
#import "PlayerUIView.h"
#import "GdriveAlertInterface.h"

@interface AssembleRoundViewController : UIViewController <GdriveAlertInterface>

@property Tournament *tourneyMO;
@property Round *roundMO;

@property PlayerUIView *draggedView;
@property CGRect selectedFrame;
@property CGPoint selectedPoint;
@property NSManagedObjectContext *theTournamentContext;
@end
