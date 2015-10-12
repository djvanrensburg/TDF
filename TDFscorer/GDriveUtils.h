//
//  GDriveUtils.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/05.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "Tournament.h"
#import "GdriveAlertInterface.h"

@interface GDriveUtils : NSObject

- (GDriveUtils *)init:(id<GdriveAlertInterface>) caller;
- (void)saveToGDrive:(NSString *)idTourney tourInst:(NSDictionary *)tourInstNS fileID:(NSString *)fileID players:(NSArray *)players suppressAlert:(BOOL)suppressAlert doShare:(BOOL)doShare tourName:(NSString *)tourName;
- (void) addUsersToShare:(NSString *)fileId players:(NSArray *)players spectators:(NSArray *)spectators tourName:(NSString *)tourName;
- (void)loadListFromGdrive:(NSMutableArray *)tournamentList managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (GTMOAuth2ViewControllerTouch *)createAuthController;
- (BOOL)isAuthorized;
- (void)loadFileFromGdrive:(NSString *)fileID managedObjectContext:(NSManagedObjectContext *)managedObjectContext suppressAlert:(BOOL)suppressAlert;
- (void)revokeToken;

@end
