//
//  TourneyList.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//


#import "TourneyList.h"
#import <CoreData/CoreData.h>
#import "AddTourneyViewController.h"
#import "Tournament.h"
#import "UIObjects.h"
#import "Constants.h"
#import "Team.h"
#import "CoreDataUtil.h"
#import "GDriveUtils.h"
#import "AppDelegate.h"
#import "GDriveFilesViewController.h"
#import "Self.h"
#import "SpectatorSelViewController.h"
@interface TourneyList ()


@property Tournament *selectedTournamentMO;
@property GDriveUtils *gDriveUtil;
@property SpectatorSelViewController *popupVC;
@property Self *myself;
//@property NSManagedObjectContext *fetchTournamentContext;
@property GTLDriveFileList *gdriveFileList;
//@property UIView *actionView;

@end

@implementation TourneyList

/*-------------------
 Initiators
 --------------------*/
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gDriveUtil = [[GDriveUtils alloc] init:self];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    if (self.directImmportedTourney != nil) {
        [self replaceWithImported:self.directImmportedTourney];
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.theTournamentContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
//                [self.tableView reloadData];
    }
}
/*-------------------
 Actions
 --------------------*/
- (IBAction)syncFromGdrive:(id)sender {
        if ([self.gDriveUtil isAuthorized]){
            [self loadFromGdrive];
        }else{
            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
            [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
        }
}

/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    // Fetch the devices from persistent data store
    if (self.theTournamentContext == nil) {
        self.theTournamentContext = [self managedObjectContext];
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tournament"];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.myself = appDelegate.myselfMO;
    
    self.tourneys = [[self.theTournamentContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creation_date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.tourneys sortUsingDescriptors:sortDescriptors];
    if (self.tourneys.count > 0) {
        [self.tableView reloadData];
    }
}
/*-------------------
 Helpers
 --------------------*/
/*------------------------
 Google Drive operations
 -------------------------*/

-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    if ([crud isEqualToString:@"r"]) {
//        UITableView * table = (UITableView *)self.view;
//        [table reloadData];
        self.gdriveFileList = (GTLDriveFileList *)anyObject;
        [self performSegueWithIdentifier:@"gDriveFileList" sender:self];
    }else{
        self.selectedTournamentMO.gDriveFileID = crud;
        self.selectedTournamentMO.internetPlay = [NSNumber numberWithBool:YES];
        NSError *error = nil;
        // Save the object to persistent store
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

#pragma move below to TourneyList
- (void)loadFromGdrive {
    if ([self.gDriveUtil isAuthorized]){
        [self.gDriveUtil loadListFromGdrive:self.tourneys managedObjectContext:self.theTournamentContext];
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
    }
}

- (void)saveToGDrive {
    NSDictionary *tourInstNS = [self.selectedTournamentMO toDictionary:NO];//YES to not save photos in file. When photos áre saved, when first round is assembled, the photos are not synced anymore. So by then all players should have imported the Tournament
    NSArray *players = [self.selectedTournamentMO.hasPlayers allObjects];
    if ([self.gDriveUtil isAuthorized]){
        [self.gDriveUtil saveToGDrive:self.selectedTournamentMO.id_of_Tournament tourInst:tourInstNS fileID:self.selectedTournamentMO.gDriveFileID players:players suppressAlert:NO doShare:YES tourName:self.selectedTournamentMO.tournamentName];
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
    }

}
/*-------------------
 Alerts
 --------------------*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 5) {
        //spectator
        if (buttonIndex == 1) {
            if ([self.gDriveUtil isAuthorized]){
                [self performSegueWithIdentifier:@"shareEmail" sender:self];
            }else{
                // Not yet authorized, request authorization and push the login UI onto the navigation stack.
                [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
            }
        }
    }else{
        //player
        if (buttonIndex == 1) {
            //upload
            if ([self.gDriveUtil isAuthorized]){
                [self saveToGDrive];
            }else{
                // Not yet authorized, request authorization and push the login UI onto the navigation stack.
                [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
            }
        }
        if ((alertView.tag == 1 && buttonIndex == 2) || (alertView.tag == 3 && buttonIndex == 2)) {
            //Share with spectators
            if ([self.gDriveUtil isAuthorized]){
                [self performSegueWithIdentifier:@"shareEmail" sender:self];
            }else{
                // Not yet authorized, request authorization and push the login UI onto the navigation stack.
                [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
            }
        }
        if ((alertView.tag == 1 && buttonIndex == 3) || (alertView.tag == 2 && buttonIndex == 2)) {
            //Edit
            if ([self.selectedTournamentMO.admin isEqualToString:self.myself.email] || self.selectedTournamentMO.admin == nil) {
                [self performSegueWithIdentifier:@"showTour" sender:self];
            }else{
                NSString *mes = [NSString stringWithFormat:@"%@%@",@"Your are not the administrator of this Tournament. Contact the administrator for changes: ",self.selectedTournamentMO.admin];
                [UIObjects showAlert:@"Edit Tournament" message:mes tag:2];
            }
        }
    }
}

/*-------------------
 Others
 --------------------*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*-------------------
 Tables
 --------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tourneys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tourneyCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    Tournament *tourney = [self.tourneys objectAtIndex:indexPath.row];
    cell.textLabel.text = tourney.tournamentName;
    NSData *tourneyPicture = tourney.icon;
    UIImage *photo = [UIImage imageWithData:tourneyPicture];
    
    cell.imageView.image = photo;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.borderWidth = 2.0;
    cell.imageView.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedTournamentMO = [self.tourneys objectAtIndex:indexPath.row];
    UIAlertView *optionsPopup;
    BOOL mePlaying = NO;
    for (PlayerInTourney *player in self.selectedTournamentMO.hasPlayers) {
        if ([self.myself.email isEqualToString:player.email]) {
            mePlaying = YES;
            break;
        }
    }
    if (mePlaying) {
        if ([self.selectedTournamentMO.status isEqualToString:@"in progress"] || [self.selectedTournamentMO.status isEqualToString:@"completed"]) {
            //Can't Edit
            if (self.selectedTournamentMO.gDriveFileID == nil) {
                optionsPopup = [[UIAlertView alloc] initWithTitle:@"Tournament Options"
                                                          message:@"You can Share this Tournament"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Upload and Share with Players",nil];
                optionsPopup.tag = 4; //upload
            }else{
                optionsPopup = [[UIAlertView alloc] initWithTitle:@"Tournament Options"
                                                          message:@"You can Share this Tournament"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Upload and Share with Players",@"Share with Spectators",nil];
                
                optionsPopup.tag = 3; //upload,share
            }
        }else{
            //Can Edit
            if (self.selectedTournamentMO.gDriveFileID == nil) {
                optionsPopup = [[UIAlertView alloc] initWithTitle:@"Tournament Options"
                                                          message:@"You can Share or Edit this Tournament"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Upload and Share with Players", @"Edit",nil];
                optionsPopup.tag = 2; //upload,edit
            }else{
                optionsPopup = [[UIAlertView alloc] initWithTitle:@"Tournament Options"
                                                          message:@"You can Share or Edit this Tournament"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Upload and Share with Players",@"Share with Spectators", @"Edit",nil];
                optionsPopup.tag = 1;//upload,share,edit
            }
        }
    }else{
        //I'm a spectator
        optionsPopup = [[UIAlertView alloc] initWithTitle:@"Tournament Options"
                                                  message:@"You can Share this Tournament"
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Share with Spectators",nil];
        optionsPopup.tag = 5;
    }
    [optionsPopup show];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        //for debugging deleting all Tournaments
//        for (Tournament *tourney in self.tourneys) {
//            [managedObjectContext deleteObject:tourney];
//        }
        Tournament *tourney = [self.tourneys objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:tourney];
        [self.tourneys removeObjectAtIndex: [indexPath row]];
        [self.tableView reloadData];
        NSError *errorMO = nil;
        // Save the object to persistent store
        if (![managedObjectContext save:&errorMO]) {
            NSLog(@"Can't Save! %@ %@", errorMO, [errorMO localizedDescription]);
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Functions
 --------------------*/
-(void)replaceWithImported:(Tournament *)newTournamentMO{
    BOOL newFriends = NO;
    BOOL newCourses = NO;
    if ([newTournamentMO.hasRounds count] > 1 || [newTournamentMO.hasPlayers count] > 8) {
#ifdef LITEVERSION
        [UIObjects showAlert:@"Lite Version" message:@"Tournament(s) synced, but some were ignored due to Lite version constraints" tag:1];
        [self.theTournamentContext deleteObject:newTournamentMO];
        newTournamentMO = nil;
#endif
    }
    if (newTournamentMO != nil) {
        newFriends = [CoreDataUtil assignPicturesFromLib:newTournamentMO managedContext:self.theTournamentContext];
        newCourses = [CoreDataUtil addCourseToLib:newTournamentMO managedContext:self.theTournamentContext];

        for(Tournament *inst in self.tourneys){ //loop over iPhone instances
            if ([inst.id_of_Tournament isEqualToString:newTournamentMO.id_of_Tournament]) { //match
                //cleanup
                [self.tourneys removeObject:inst];//remove iPhone instance
                [self.theTournamentContext deleteObject:inst];
                
                break;
            }
        }
        [self.tourneys addObject:newTournamentMO];//add gDrive instance

        if (newFriends || newCourses) {
            [UIObjects showAlert:@"New Friends/Courses" message:@"Some new friends/courses were added" tag:1];
        }

    }
}
/*-------------------
 Exits
 --------------------*/

- (IBAction)unwindToTourneyList:(UIStoryboardSegue *)segue {
    NSObject *obj = [segue sourceViewController];
        if ([segue.identifier isEqualToString:@"spectatorSel"]){
            SpectatorSelViewController *specVC = (SpectatorSelViewController *)obj;
            if ([specVC.emailAR count] > 0) {
                    [self.gDriveUtil addUsersToShare:self.selectedTournamentMO.gDriveFileID players:nil spectators:specVC.emailAR tourName:self.selectedTournamentMO.tournamentName];
            }
        }else if( [segue.identifier isEqualToString:@"importedTourney"]){
            GDriveFilesViewController *gFilesVC = (GDriveFilesViewController *)obj;
            //find matching tournament
            [self replaceWithImported:gFilesVC.importedTourneyMO];
            [self.tableView reloadData];
        }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    BOOL retVal = YES;
    if ([identifier isEqualToString:@"gDriveFileList"]){
        if ([self.gdriveFileList.items count] == 0) {
            [UIObjects showAlert:@"Google Drive" message:@"There are no Tournaments on your Google Drive" tag:1];
            retVal = NO;
        }
    }
    return retVal;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showTour"]) {
        AddTourneyViewController *addTourneyViewController = (AddTourneyViewController *)[segue destinationViewController];

        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        addTourneyViewController.tournamentMO = self.tourneys[myIndexPath.row];
        addTourneyViewController.theTournamentContext = self.theTournamentContext;
    }else if ([[segue identifier] isEqualToString:@"addTour"]){
        AddTourneyViewController *addTourneyViewController = (AddTourneyViewController *)[segue destinationViewController];

        addTourneyViewController.theTournamentContext = [self managedObjectContext];//new context
    }else if ([segue.identifier isEqualToString:@"shareEmail"]){
        self.popupVC = segue.destinationViewController;
        if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]){
            //iOS 8.0 and above
            self.popupVC.providesPresentationContextTransitionStyle = YES;
            self.popupVC.definesPresentationContext = YES;
            
            [self.popupVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        }else{
            [self.popupVC setModalPresentationStyle:UIModalPresentationCurrentContext];
            [self.popupVC.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
        }
    }else if ([segue.identifier isEqualToString:@"gDriveFileList"]){
        GDriveFilesViewController *fileListViewController = (GDriveFilesViewController *)[segue destinationViewController];

        fileListViewController.gdriveFileList = self.gdriveFileList;
        fileListViewController.theTournamentContext = self.theTournamentContext;
    }
}



@end
