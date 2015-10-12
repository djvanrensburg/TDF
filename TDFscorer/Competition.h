//
//  Competition.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/26.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"

@class Round;

@interface Competition : NSManagedObject

@property (nonatomic, retain) NSString * compType;
@property (nonatomic, retain) NSNumber * isHighHCtoZero;
@property (nonatomic, retain) NSNumber * isTeamComp;
@property (nonatomic, retain) NSNumber * isOneOnOne;
@property (nonatomic, retain) NSSet *appliesToRound;
@end

@interface Competition (CoreDataGeneratedAccessors)

- (void)addAppliesToRoundObject:(Round *)value;
- (void)removeAppliesToRoundObject:(Round *)value;
- (void)addAppliesToRound:(NSSet *)values;
- (void)removeAppliesToRound:(NSSet *)values;

@end
