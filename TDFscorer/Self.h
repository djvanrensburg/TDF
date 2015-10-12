//
//  Self.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/22.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import "NSManagedObject.h"
#import "NSManagedObject+Serialization.h"
#import "Friend.h"

@interface Self : Friend

@property (nonatomic, retain) NSString * favTournament;
@property (nonatomic, retain) NSNumber * numberOfTourneys;
@property (nonatomic, retain) NSNumber * rankingPoints;

@end
