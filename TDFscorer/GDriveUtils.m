//
//  GDriveUtils.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/05.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import "GDriveUtils.h"
#import "Constants.h"
#import "UIObjects.h"
#import <CoreData/CoreData.h>
#import "zlib.h"
#import "Tournament.h"
#import "CoreDataUtil.h"

@interface GDriveUtils()

@property GTLServiceDrive *driveService;
@property NSObject<GdriveAlertInterface> *caller;
@property UIAlertView *uiAlert;
@property Tournament *driveTournament;
@property NSString *successFileID;
@end

@implementation GDriveUtils

- (GDriveUtils *)init:(id<GdriveAlertInterface>) caller{
    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];
    self.caller = caller;
    return self;
}

- (UIAlertView*)showAlert:(NSString *)title message:(NSString *)message tag:(int)tag{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: self
                             cancelButtonTitle: nil
                             otherButtonTitles: @"OK", nil];
    alert.tag = tag;
    [alert show];
    return alert;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 103) {
        [self.caller notifyOfGdriveComplete:@"r" object:nil];
    }else if (alertView.tag == 102){
        [self.caller notifyOfGdriveComplete:@"r" object:self.driveTournament];
    }else if (alertView.tag == 101){
        [self.caller notifyOfGdriveComplete:self.successFileID object:nil];
    }
}

+(NSData*) gzipData: (NSData*)pUncompressedData{
    if (!pUncompressedData || [pUncompressedData length] == 0){
        NSLog(@"%s: Error: Can't compress an empty or null NSData object.", __func__);
        return nil;
    }
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc    = Z_NULL; // Set zalloc, zfree, and opaque to Z_NULL so
    zlibStreamStruct.zfree     = Z_NULL; // that when we call deflateInit2 they will be
    zlibStreamStruct.opaque    = Z_NULL; // updated to use default allocation functions.
    zlibStreamStruct.total_out = 0; // Total number of output bytes produced so far
    zlibStreamStruct.next_in   = (Bytef*)[pUncompressedData bytes]; // Pointer to input bytes
    zlibStreamStruct.avail_in  = [pUncompressedData length]; // Number of input bytes left to process
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK)
    {
        NSString *errorMsg = nil;
        switch (initError)
        {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: deflateInit2() Error: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
//        [errorMsg release];
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 12];
    
    int deflateStatus;
    do{
        // Store location where next byte should be put in next_out
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    }while ( deflateStatus == Z_OK );
    
    if (deflateStatus != Z_STREAM_END){
        NSString *errorMsg = nil;
        switch (deflateStatus)
        {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        NSLog(@"%s: zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
//        [errorMsg release];
        
        // Free data structures that were dynamically created for the stream.
        deflateEnd(&zlibStreamStruct);
        
        return nil;
    }
    // Free data structures that were dynamically created for the stream.
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength: zlibStreamStruct.total_out];
    NSLog(@"%s: Compressed file from %d KB to %d KB", __func__, [pUncompressedData length]/1024, [compressedData length]/1024);
    
    return compressedData;
}

+ (NSData*)gunzipData:(NSData *)compressedData error:(NSError *)error{

    if(compressedData.length < 18){
        if(error)
//            *error = [NSError errorWithDomain:IDZGunzipErrorDomain code:Z_DATA_ERROR userInfo:nil];
        return nil;
    }
    z_stream zStream;
    memset(&zStream, 0, sizeof(zStream));
    /*
     * 16 is a magic number that allows inflate to handle gzip
     * headers.
     */
    int iResult = inflateInit2(&zStream, 16);
    if(iResult != Z_OK){
        if(error)
//            *error = [NSError errorWithDomain:IDZGunzipErrorDomain code:iResult userInfo:nil];
        return nil;
    }
    UInt32 nUncompressedBytes = *(UInt32*)(compressedData.bytes + compressedData.length - 4);
    NSMutableData* gunzippedData = [NSMutableData dataWithLength:nUncompressedBytes];
    
    zStream.next_in = (Bytef*)compressedData.bytes;
    zStream.avail_in = compressedData.length;
    zStream.next_out = (Bytef*)gunzippedData.bytes;
    zStream.avail_out = gunzippedData.length;
    
    iResult = inflate(&zStream, Z_FINISH);
    if(iResult != Z_STREAM_END)
    {
        if(error)
//            *error = [NSError errorWithDomain:IDZGunzipErrorDomain code:iResult userInfo:nil];
        gunzippedData = nil;
    }
    inflateEnd(&zStream);
    return gunzippedData;
}

- (void)saveToGDrive:(NSString *)idTourney tourInst:(NSDictionary *)tourInstNS fileID:(NSString *)fileID players:(NSArray *)players suppressAlert:(BOOL)suppressAlert doShare:(BOOL)doShare tourName:(NSString *)tourName{
    GTLDriveFile *file = [GTLDriveFile object];
    GTLServiceTicket *gticket;
    GTLQueryDrive *query;
    
    file.title = [NSString stringWithFormat:@"%@%@", idTourney, @".tdf"];
    file.mimeType = @"text/xml";
    file.descriptionProperty = @"Uploaded from Tour de Force";
    NSString *errorStr;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:tourInstNS format:NSPropertyListXMLFormat_v1_0 options:0 error:&errorStr];
    data = [GDriveUtils gzipData:data];
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:data MIMEType:file.mimeType];
    
    UIAlertView *waitIndicator = [UIObjects showWaitIndicator:@"Saving to Google Drive"];
    if (fileID != nil){
        NSLog(@"File existed, overwrite: %@", fileID);
        query = [GTLQueryDrive queryForFilesUpdateWithObject:file fileId:fileID uploadParameters:uploadParameters];
    }else{ //new file
        query = [GTLQueryDrive queryForFilesInsertWithObject:file uploadParameters:uploadParameters];
    }
    gticket = [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *driveFile, NSError *error) {
        [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
        if (error == nil){
            self.successFileID = driveFile.identifier;
            
            NSLog(@"File ID: %@", driveFile.identifier);
            if (doShare) {
                //now share the file
                [self addUsersToShare: driveFile.identifier players:players spectators:nil tourName:tourName];
            }
            
            if (!suppressAlert){
                self.uiAlert = [self showAlert:@"Google Drive" message:@"File saved!" tag:101];
            }else{
                [self.caller notifyOfGdriveComplete:self.successFileID object:nil];
            }
        
        }else{
            self.successFileID = nil;
            NSLog(@"An error occurred: %@", error);
            if (error.code == 400) {
            }
            self.uiAlert = [self showAlert:@"Google Drive" message:@"Sorry, an error occurred!" tag:99];
        }
    }];
}

- (void) addUsersToShare:(NSString *)fileId players:(NSArray *)players spectators:(NSArray *)spectators tourName:(NSString *)tourName{
    GTLServiceTicket *gticket;
    NSString *emailMessage;
    
    UIAlertView *waitIndicator;
    if ([spectators count] > 0){
        waitIndicator = [UIObjects showWaitIndicator:@"Sharing Google Drive file"];
    }
    NSMutableArray *emailAddrAR = [[NSMutableArray alloc] init];
    for ( PlayerInTourney *player in players) {
        [emailAddrAR addObject:player.email];
    }
    for (NSString *email in spectators) {
        [emailAddrAR addObject:email];
    }
    for ( NSString *emailAddr in emailAddrAR) {
        GTLDrivePermission *permission = [GTLDrivePermission object];
        permission.value = emailAddr;
        permission.type = @"user";
        permission.role = @"writer";
        GTLQueryDrive *query = [GTLQueryDrive queryForPermissionsInsertWithObject:permission fileId:fileId ];
        NSString *link = [NSString stringWithFormat:@"%s%@","TDFscorer://?fileID=",fileId];
        emailMessage = [NSString stringWithFormat:@"%@%@%@%@",@"To upload Tournament ",tourName,@" in your app navigate to Tourney -> Tap 'Sync' or click on this link: ",link ];
        query.emailMessage = emailMessage;
        gticket = [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDrivePermission *permissionRet, NSError *error) {
            if ([spectators count] > 0){
                [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
            }
            if (error == nil) {
                if ([spectators count] > 0){
                    self.uiAlert = [self showAlert:@"Google Drive" message:@"Tournament shared with email addresses" tag:104];
                }
                NSLog(@"File Shared with: %@", emailAddr);
            } else {
                NSLog(@"An error occurred: %@", error);
//                self.uiAlert = [self showAlert:@"Google Drive" message:error.description tag:99];
            }
        }];
    }
}

- (void)loadListFromGdrive:(NSMutableArray *)tournamentList managedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    GTLServiceTicket *gticket;
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ) fromDate:[[NSDate alloc] init]];
    [components setMonth:([components month] - 6)];
    NSDate *lastMonth = [cal dateFromComponents:components];
    NSTimeZone *localTimeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    [rfc3339DateFormatter setTimeZone:localTimeZone];
    
    NSString *dateString = [rfc3339DateFormatter stringFromDate:lastMonth];
    
    NSString *fileSearch = [NSString stringWithFormat:@"%@%@%s",@"title contains '.tdf' and trashed = false and modifiedDate > '",dateString,"'"];
    NSString *qstring = [NSString stringWithFormat:@"%@%@%@%s", fileSearch, @" or ( sharedWithMe and ",fileSearch," )"];
    query.q = qstring;
    
    UIAlertView *waitIndicator = [UIObjects showWaitIndicator:@"Querying Google Drive"];
    
    gticket = [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList *files, NSError *error) {
        if (!error) {
            [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
            [self.caller notifyOfGdriveComplete:@"r" object:files];
        } else {
            [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
            NSLog(@"An error occurred: %@", error);
            self.uiAlert = [self showAlert:@"Google Drive" message:error.description tag:99];
        }

    }];
}

- (void)loadFileFromGdrive:(NSString *)fileID managedObjectContext:(NSManagedObjectContext *)managedObjectContext suppressAlert:(BOOL)suppressAlert{
    NSString *errorStr;
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesGetWithFileId:fileID];
    GTLServiceTicket *gticket;
    
    UIAlertView *waitIndicator = [UIObjects showWaitIndicator:@"Syncing..."];
    
    gticket = [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile *file, NSError *error){
        if (error == nil) {
            NSLog(@"Have results");
            if (file.labels.trashed.intValue != 1 ){ //only non-trashed
                //Convert file to Dictionary
                GTMHTTPFetcher *fetcher = [self.driveService.fetcherService fetcherWithURLString:file.downloadUrl];
                [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                    [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                    if (error == nil) {
                        NSLog(@"Retrieved file content");
                        // Do something with data
                        NSPropertyListFormat format;
                        data = [GDriveUtils gunzipData:data error:nil];
                        id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:&errorStr];
                        Tournament *tourneyNewMO;
                        @try {
                            tourneyNewMO = [NSEntityDescription insertNewObjectForEntityForName:@"Tournament" inManagedObjectContext:managedObjectContext];
                            [tourneyNewMO populateFromDictionary:plist context:managedObjectContext];
                            tourneyNewMO.gDriveFileID = fileID;
                            if (!suppressAlert) {
                                self.uiAlert = [self showAlert:@"Google Drive" message:@"Tournament synced" tag:102];
                                self.driveTournament = tourneyNewMO;
                            }else{
                                [self.caller notifyOfGdriveComplete:@"r" object:tourneyNewMO];
                            }
                        }@catch (NSException *exception) {
                            [managedObjectContext deleteObject:tourneyNewMO];
                            NSLog(@"An error occurred: %@", exception.description);
                            //                            [managedObjectContext deleteObject:tourneyNewMO];
                            self.uiAlert = [self showAlert:@"Google Drive" message:@"The Google Drive file is corrupt or not compatible with this app" tag:99];
                        }
                    } else {
                        NSLog(@"An error occurred: %@", error);
                        self.uiAlert = [self showAlert:@"Google Drive" message:error.description tag:99];
                        //                        [managedObjectContext deleteObject:tourneyNewMO];
                    }
                }];
                
//                [self.driveService.fetcherService waitForCompletionOfAllFetchersWithTimeout:360];
            }else{
                [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                NSString *mes = [NSString stringWithFormat:@"%@%@%@",@"No file with ID:",fileID,@" exists"];
                self.uiAlert = [self showAlert:@"Google Drive" message:mes tag:99];
            }
        } else {
            [waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                NSLog(@"An error occurred: %@", error);
                self.uiAlert = [self showAlert:@"Google Drive" message:error.description tag:99];
        }
    }];
    
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)createAuthController{
    GTMOAuth2ViewControllerTouch *authController;
    //kGTLAuthScopeDriveFile
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                                clientID:kClientID
                                                            clientSecret:kClientSecret
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

- (BOOL)isAuthorized{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
//    return self.driveService.authorizer.canAuthorize;
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error {
    if (error != nil){
        self.uiAlert = [self showAlert:@"Authentication Error" message:error.localizedDescription tag:99];
        self.driveService.authorizer = nil;
    }else{
        self.driveService.authorizer = authResult;
        [self.caller notifyOfGdriveComplete:viewController.authentication.userEmail object:nil];
    }
}

- (void)revokeToken{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.driveService.authorizer];
}

//Not in use
- (GTLDriveParentReference *)createGoogleRootFolder{
    GTLDriveParentReference *parent = [GTLDriveParentReference object];
    __block BOOL doesNotExist;
    GTLDriveFile *folder = [GTLDriveFile object];
    folder.title = @"Tour de Force Mobile App";
    folder.mimeType = @"application/vnd.google-apps.folder";
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = @"Tour de Force Mobile App";
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLDriveFile *updatedFile,
                                                              NSError *error) {
        if (error != nil){
            parent.identifier = updatedFile.identifier;
            doesNotExist = NO;
        }else{
            doesNotExist = YES;
        }
    }];
    
    if (doesNotExist) {
        
        query = [GTLQueryDrive queryForFilesInsertWithObject:folder uploadParameters:nil];
        
        [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                                  GTLDriveFile *updatedFile,
                                                                  NSError *error) {
            if (error == nil) {
                NSLog(@"Created folder");
                parent.identifier = updatedFile.identifier;
            } else {
                NSLog(@"An error occurred: %@", error);
            }
        }];
    }
    
    return parent;
}
@end
