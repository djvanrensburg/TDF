//
//  Round.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/10.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class Competition, Course, Group, Tournament;

@interface Round : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * numHolesCompleted;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * teeTime;
@property (nonatomic, retain) NSSet *hasComp;
@property (nonatomic, retain) NSSet *hasGroups;
@property (nonatomic, retain) Course *isOfCourse;
@property (nonatomic, retain) Tournament *isPlayedInTourney;
@end

@interface Round (CoreDataGeneratedAccessors)

- (void)addHasCompObject:(Competition *)value;
- (void)removeHasCompObject:(Competition *)value;
- (void)addHasComp:(NSSet *)values;
- (void)removeHasComp:(NSSet *)values;

- (void)addHasGroupsObject:(Group *)value;
- (void)removeHasGroupsObject:(Group *)value;
- (void)addHasGroups:(NSSet *)values;
- (void)removeHasGroups:(NSSet *)values;

@end
