//
//  Hole.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/01.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class Course;

@interface Hole : NSManagedObject

@property (nonatomic, retain) NSNumber * holeNumber;
@property (nonatomic, retain) NSNumber * par;
@property (nonatomic, retain) NSNumber * result;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * stroke;
@property (nonatomic, retain) NSNumber * teamScore;
@property (nonatomic, retain) Course *partOfCourse;

@end
