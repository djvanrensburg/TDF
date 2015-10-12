//
//  Tournament.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/10.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class PlayerInTourney, Round, Team;

@interface Tournament : NSManagedObject

@property (nonatomic, retain) NSString * admin;
@property (nonatomic, retain) NSDate * creation_date;
@property (nonatomic, retain) NSString * gDriveFileID;
@property (nonatomic, retain) NSString * id_of_Tournament;
@property (nonatomic, retain) NSNumber * internetPlay;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * scoringType;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSSet *hasPlayers;
@property (nonatomic, retain) NSSet *hasRounds;
@property (nonatomic, retain) NSSet *hasTeams;
@end

@interface Tournament (CoreDataGeneratedAccessors)

- (void)addHasPlayersObject:(PlayerInTourney *)value;
- (void)removeHasPlayersObject:(PlayerInTourney *)value;
- (void)addHasPlayers:(NSSet *)values;
- (void)removeHasPlayers:(NSSet *)values;

- (void)addHasRoundsObject:(Round *)value;
- (void)removeHasRoundsObject:(Round *)value;
- (void)addHasRounds:(NSSet *)values;
- (void)removeHasRounds:(NSSet *)values;

- (void)addHasTeamsObject:(Team *)value;
- (void)removeHasTeamsObject:(Team *)value;
- (void)addHasTeams:(NSSet *)values;
- (void)removeHasTeams:(NSSet *)values;

@end
