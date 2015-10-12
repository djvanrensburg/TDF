//
//  TournamentInstance.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/05.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import "TournamentInstance.h"
#import "PlayerInTourney.h"
#import "Round.h"
#import "Tournament.h"


@implementation TournamentInstance

@dynamic admin;
@dynamic internetPlay;
@dynamic location;
@dynamic scoringType;
@dynamic status;
@dynamic tournamentName;
@dynamic creation_date;
@dynamic id_of_Tournament;
@dynamic year;
@dynamic gDriveFileID;
@dynamic hasPlayers;
@dynamic hasRounds;
@dynamic yearInstance;

//- (NSMutableSet*) serializationObjectsToSkip{
//    NSMutableSet* objectsToSkip = [NSMutableSet new];
//    
//    //Here you select objects that relate to this object and you don't want to serialise.
//    //Insert them into `objectsToSkip`
//    [objectsToSkip addObject:self.yearInstance];
//    return objectsToSkip;
//}

@end
