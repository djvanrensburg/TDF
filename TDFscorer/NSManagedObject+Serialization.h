//
//  NSManagedObject+Serialization.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/05.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (Serialization)

- (NSDictionary*) toDictionary:(BOOL)ignoreDataPhoto;

- (void) populateFromDictionary:(NSDictionary*)dict context:(NSManagedObjectContext*)context;// intoEmptyCtx:(BOOL)intoEmptyCtx;

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;

@end