//
//  RoundsInPlayViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/14.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "RoundsInPlayViewController.h"
#import "Round.h"
#import "Tournament.h"
#import "Course.h"
#import "Constants.h"
#import "AssembleRoundViewController.h"
#import "ScoringViewController.h"
#import "TeamLeaderboardViewController.h"
#import "LeaderboardTableViewController.h"
#import "AppDelegate.h"
#import "Self.h"
#import "GDriveUtils.h"
#import "CoreDataUtil.h"

#import "UIObjects.h"
//static NSString *const kKeychainItemName = @"Tour de Force";
//static NSString *const kClientID = @"975845056051-vhv2p9oep2eci5huci5m5vobh0sd5p8e.apps.googleusercontent.com";
//static NSString *const kClientSecret = @"kzBkiq10JQzxl1gfPVtkgl7P";

@interface RoundsInPlayViewController ()

@property (weak, nonatomic) IBOutlet UITableView *roundTV;
@property (weak, nonatomic) IBOutlet UIProgressView *tourneyProgress;
@property NSArray *roundsAR;
@property (strong, nonatomic) IBOutlet UIButton *skipAssemblyBT;
@property (nonatomic) float progressValue;
@property (weak, nonatomic) IBOutlet UISwitch *InternetSW;
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property Self *myself;
@property GDriveUtils *gDriveUtil;

@end

@implementation RoundsInPlayViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void) viewDidAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = NO;
    if (self.tourneyProgress.progress == 1.0) {
        self.tourneyMO.status = @"completed";
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.theTournamentContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (void)viewDidLoad {
    self.gDriveUtil = [[GDriveUtils alloc]init:self];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.myself = appDelegate.myselfMO;
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    
    self.roundTV.clipsToBounds = YES;
    self.roundTV.layer.cornerRadius = 8.0;
    self.roundTV.layer.borderWidth = 2.0;
    self.roundTV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.roundTV.backgroundColor = [UIColor clearColor];
    
    self.title = self.tourneyMO.tournamentName;
    
    self.tourneyProgress.trackImage = [UIImage imageNamed:@"tourney.jpg"];
    
    [self loadData];
    
    [self updateProgressBar];
    //check if any photos need to be assigned
    NSManagedObjectContext *friendContext = [self managedObjectContext];
    [CoreDataUtil assignPicturesFromLib:self.tourneyMO managedContext:friendContext];
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theTournamentContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    //if I'm a spectator disable Play through Internet and also table view for rounds
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@",self.myself.email];
    if ([[self.tourneyMO.hasPlayers filteredSetUsingPredicate:predicate] count] == 0) {
        self.InternetSW.enabled = NO;
        self.roundTV.userInteractionEnabled = NO;
    }
}
/*-------------------
 Actions
 --------------------*/
- (IBAction)toggleInternetPlay:(id)sender {
    if (self.InternetSW.isOn) {
        if (self.tourneyMO.gDriveFileID == nil) {
            [UIObjects showAlert:@"Google Drive" message:@"This Tournament is not yet uploaded to your Google Drive. Please share the tournament from the Tourney Page before selecting this option." tag:1];
            [self.InternetSW setOn:NO];
            return;
        }
        if ([self.gDriveUtil isAuthorized]){
        }else{
            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
            [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
        }
    }
    self.tourneyMO.internetPlay = [NSNumber numberWithBool:self.InternetSW.isOn];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theTournamentContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (IBAction)sync:(id)sender {
    if ([self.gDriveUtil isAuthorized]){
//        NSManagedObjectContext *tempTournamentContext = [self managedObjectContext];
        [self.gDriveUtil loadFileFromGdrive:self.tourneyMO.gDriveFileID managedObjectContext:self.theTournamentContext suppressAlert:NO];
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
    }
}

/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.roundsAR = [[[self.tourneyMO hasRounds] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    BOOL isOn = [self.tourneyMO.internetPlay boolValue];
    [self.InternetSW setOn:isOn];
}

/*-------------------
 Helpers
 --------------------*/
-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    [self.theTournamentContext deleteObject:self.tourneyMO] ;

    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theTournamentContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }

    self.tourneyMO = (Tournament *)anyObject;
    [CoreDataUtil assignPicturesFromLib:self.tourneyMO managedContext:self.theTournamentContext];
    [self loadData];
}

//- (BOOL)isAuthorized{
//    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
//}
//
//// Creates the auth controller for authorizing access to Google Drive.
//- (GTMOAuth2ViewControllerTouch *)createAuthController{
//    GTMOAuth2ViewControllerTouch *authController;
//    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
//                                                                clientID:kClientID
//                                                            clientSecret:kClientSecret
//                                                        keychainItemName:kKeychainItemName
//                                                                delegate:self
//                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
//    return authController;
//}
//
//// Handle completion of the authorization process, and updates the Drive service
//// with the new credentials.
//- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error {
//    if (error != nil){
//        [self showAlert:@"Authentication Error" message:error.localizedDescription otherBut:nil];
//        self.driveService.authorizer = nil;
//    }else{
//        self.driveService.authorizer = authResult;
//    }
//}

- (void) updateProgressBar{
    float quotient = 0.0;
    for (Round *round in self.roundsAR) {
        if ([round.status isEqualToString:@"completed"]) {
            quotient = quotient + 1.0;
        }else if ([round.status isEqualToString:@"in progress"]){
            quotient = quotient + 0.5;
        }
    }
    self.progressValue = quotient / [self.roundsAR count];
    if (isinf(self.progressValue)) {
        self.progressValue = 0.0;
    }
    self.tourneyProgress.progress = self.progressValue;
}
/*-------------------
 Alerts
 --------------------*/
// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message otherBut: (NSString *)otherBut{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: otherBut, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Do Nothing
    }else if (buttonIndex == 1) {
        //Assemble
        [self performSegueWithIdentifier:@"assembleRound2" sender:self];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.roundsAR count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roundsCell" forIndexPath:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    NSNumber *counter = [NSNumber numberWithInt:indexPath.row + 1];
    Round *roundMO = [self.roundsAR objectAtIndex:indexPath.row];
    Course *course = [roundMO isOfCourse];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%s%@",@"Round " ,counter.stringValue, ": ",  course.courseName];
    //    [cell setBackgroundColor:[UIColor clearColor]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy hh:mm"];
    cell.detailTextLabel.text = [dateFormat stringFromDate:roundMO.teeTime];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    if ([roundMO.status isEqualToString:@"completed"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    return cell;
}

/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Exits
 --------------------*/
- (IBAction)unwindToRoundsInPlay:(UIStoryboardSegue *)segue{
    if ([segue.identifier isEqualToString:@"backToRounds"]) {
        [self updateProgressBar];
        [self.roundTV reloadData];
    }
//    self.navigationController.toolbarHidden = NO;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    BOOL ret = YES;
    BOOL canPlay = NO;
    
     if ([identifier isEqualToString:@"toScoring"]) {
         //Check whether I am only a viewer
         for (PlayerInTourney *player in self.tourneyMO.hasPlayers) {
             if ([player.email isEqualToString:self.myself.email]) {
                 canPlay = YES;
                 break;
             }
         }
         if (canPlay) {
             NSIndexPath *myIndexPath = [self.roundTV indexPathForSelectedRow];
             Round *round = self.roundsAR[myIndexPath.row];
             if ([round.status isEqualToString:@"pending"]) {
                 ret = NO;
                 if ([round.isPlayedInTourney.admin isEqualToString:self.myself.email]) {
                     [self showAlert:@"Unassembled round" message:@"Tap the Assembled Round button to assemble the groups" otherBut:@"Assemble Round"];
                 }else{
                     [self showAlert:@"Unassembled round" message:@"Ask the administrator of the Tournament to assemble this round" otherBut:nil];
                 }
             }
         }else{
             ret = NO;
         }
     }
    return ret;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationController.toolbarHidden = YES;

    if ([segue.identifier isEqualToString:@"toScoring"]) {
        ScoringViewController *scoring = (ScoringViewController *)[segue destinationViewController];
        NSIndexPath *myIndexPath = [self.roundTV indexPathForSelectedRow];
        scoring.roundMO = self.roundsAR[myIndexPath.row];
        scoring.theTournamentContext = self.theTournamentContext;
//        scoring.driveService = self.driveService;
        scoring.internetPlay = self.InternetSW.isOn;
    }else if ([segue.identifier isEqualToString:@"toLeaderboard"]){
        LeaderboardTableViewController *leaderboard = (LeaderboardTableViewController *)[segue destinationViewController];
        leaderboard.tourneyMO = self.tourneyMO;
    }else if([segue.identifier isEqualToString:@"toteamLeaderboard"]){
        TeamLeaderboardViewController *teamLeaderboard = (TeamLeaderboardViewController *)[segue destinationViewController];
        teamLeaderboard.tourneyMO = self.tourneyMO;
    } else if ([[segue identifier] isEqualToString:@"assembleRound2"]){
        AssembleRoundViewController *ass_round = (AssembleRoundViewController *)[segue destinationViewController];
        ass_round.roundMO = self.roundsAR[self.roundTV.indexPathForSelectedRow.row];
        ass_round.tourneyMO = self.tourneyMO;
        ass_round.theTournamentContext = self.theTournamentContext;
    }

}

@end
