//
//  Friend.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/22.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * friendName;
@property (nonatomic, retain) NSNumber * handicap;
@property (nonatomic, retain) NSData * photo;

@end
