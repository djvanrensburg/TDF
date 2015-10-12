//
//  PlayerInTourney.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/19.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Friend.h"
#import "NSManagedObject+Serialization.h"
@class Tournament;

@interface PlayerInTourney : Friend

@property (nonatomic, retain) NSNumber * adjustedHC;
@property (nonatomic, retain) NSString * team;
@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) Tournament *playsInTourney;

@end
