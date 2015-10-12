//
//  CoreDataUtil.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Course.h"
#import "Tournament.h"

@interface CoreDataUtil : NSObject

+ (BOOL) assignPicturesFromLib:(Tournament *)instance managedContext:(NSManagedObjectContext *)managedObjectContext;
+ (BOOL) addCourseToLib:(Tournament *)instance managedContext:(NSManagedObjectContext *)managedObjectContext;
+ (UIImage *)scaleImage:(UIImage *)image withFactor:(float)factor;
//+ (Course *)courseBaseToCourse:(NSManagedObjectContext *)managedContext coursebase:(CourseBase *)courseBase;
@end
