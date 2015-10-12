//
//  AppDelegate.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Self.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property Self *myselfMO;
@property NSString *importFileID;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end