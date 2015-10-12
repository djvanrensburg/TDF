//
//  GDriveFilesViewController.h
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/26.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"
#import "GdriveAlertInterface.h"
#import "Tournament.h"
@interface GDriveFilesViewController : UIViewController <GdriveAlertInterface>

@property GTLDriveFileList *gdriveFileList;
@property NSManagedObjectContext *theTournamentContext;
@property Tournament *importedTourneyMO;
@end
