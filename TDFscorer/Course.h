//
//  Course.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/08.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CourseBase.h"
#import "NSManagedObject+Serialization.h"
@class Round;

@interface Course : CourseBase

@property (nonatomic, retain) NSSet *usedInRound;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addUsedInRoundObject:(Round *)value;
- (void)removeUsedInRoundObject:(Round *)value;
- (void)addUsedInRound:(NSSet *)values;
- (void)removeUsedInRound:(NSSet *)values;

@end
