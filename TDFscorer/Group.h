//
//  Group.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/24.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class PlayerInGroup, Round;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * groupid;
@property (nonatomic, retain) NSNumber * holeInd;
@property (nonatomic, retain) NSSet *hasPlayers;
@property (nonatomic, retain) Round *isOfRound;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addHasPlayersObject:(PlayerInGroup *)value;
- (void)removeHasPlayersObject:(PlayerInGroup *)value;
- (void)addHasPlayers:(NSSet *)values;
- (void)removeHasPlayers:(NSSet *)values;

@end
