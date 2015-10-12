//
//  CourseViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/26.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseBase.h"
@interface CourseViewController : UIViewController

@property CourseBase *courseMO;
@property NSManagedObjectContext *theCourseContext;

@end
