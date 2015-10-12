//
//  TourneyTeam.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/21.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Team.h"
#import "NSManagedObject+Serialization.h"
@class PlayerInTourney;

@interface TourneyTeam : Team

@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) NSSet *hasPlayers;
@end

@interface TourneyTeam (CoreDataGeneratedAccessors)

- (void)addHasPlayersObject:(PlayerInTourney *)value;
- (void)removeHasPlayersObject:(PlayerInTourney *)value;
- (void)addHasPlayers:(NSSet *)values;
- (void)removeHasPlayers:(NSSet *)values;

@end
