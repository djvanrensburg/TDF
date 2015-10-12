//
//  Team.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/19.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Serialization.h"
@class Tournament;

@interface Team : NSManagedObject

@property (nonatomic, retain) NSData * teamImage;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSNumber * totalPoints;
@property (nonatomic, retain) Tournament *isOfTournament;

@end
