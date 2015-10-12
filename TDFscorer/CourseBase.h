//
//  CourseBase.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/08.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class Hole;

@interface CourseBase : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * courseName;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSSet *consistOf;
@end

@interface CourseBase (CoreDataGeneratedAccessors)

- (void)addConsistOfObject:(Hole *)value;
- (void)removeConsistOfObject:(Hole *)value;
- (void)addConsistOf:(NSSet *)values;
- (void)removeConsistOf:(NSSet *)values;

@end
