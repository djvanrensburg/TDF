//
//  PlayerInGroup.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/24.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PlayerInTourney.h"
#import "NSManagedObject+Serialization.h"
@class Group, Scorecard;

@interface PlayerInGroup : PlayerInTourney

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * opponent;
@property (nonatomic, retain) NSNumber * teamPoints;
@property (nonatomic, retain) Scorecard *hasScoreCard;
@property (nonatomic, retain) NSSet *playsInGroup;
@end

@interface PlayerInGroup (CoreDataGeneratedAccessors)

- (void)addPlaysInGroupObject:(Group *)value;
- (void)removePlaysInGroupObject:(Group *)value;
- (void)addPlaysInGroup:(NSSet *)values;
- (void)removePlaysInGroup:(NSSet *)values;

@end
