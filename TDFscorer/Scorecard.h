//
//  Scorecard.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/26.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Course.h"
#import "NSManagedObject+Serialization.h"
@class PlayerInGroup;

@interface Scorecard : Course

@property (nonatomic, retain) NSNumber * holeInd;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSSet *containsPlayer;
@end

@interface Scorecard (CoreDataGeneratedAccessors)

- (void)addContainsPlayerObject:(PlayerInGroup *)value;
- (void)removeContainsPlayerObject:(PlayerInGroup *)value;
- (void)addContainsPlayer:(NSSet *)values;
- (void)removeContainsPlayer:(NSSet *)values;

@end
