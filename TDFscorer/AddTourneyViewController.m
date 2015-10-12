//
//  AddTourneyViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "AddTourneyViewController.h"
#import <CoreData/CoreData.h>
#import "Tournament.h"

#import "TourneyInstanceViewController.h"
//#import "Team.h"
#import "Group.h"
#import "Self.h"
#import "Round.h"
#import "PlayerInGroup.h"
#import "PlayerInTourney.h"
#import "TeamViewController.h"
#import "CoreDataUtil.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GDriveUtils.h"

#import "UIObjects.h"
#import "PlayerTeamSelectViewController.h"

@interface AddTourneyViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tournamentTI;
@property (weak, nonatomic) IBOutlet UIImageView *tourneyPhotoIV;
@property NSData *tourneyPicData;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTourneyBT;
@property (weak, nonatomic) IBOutlet UIButton *editPhotoBT;
@property (weak, nonatomic) IBOutlet UITableView *teamTV;
@property (weak, nonatomic) IBOutlet UITableView *playersTV;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTournamentBT;
@property (weak, nonatomic) IBOutlet UILabel *TournamentLB;
@property (weak, nonatomic) IBOutlet UIButton *addTeamBT;
@property NSMutableArray *teamsAR;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBT;
@property BOOL isNewTour;
@property Self *myself;
@property TeamViewController *popupVC;
@property NSMutableArray *friendsAR;
@property NSMutableDictionary *selectedPlayerNS;
@property PlayerInTourney *selectedPlayerMO;
@property (weak, nonatomic) IBOutlet UITextField *roundsCounterTI;
@property NSMutableArray *playersAR;
@property BOOL playerChange;
@end

@implementation AddTourneyViewController

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
    self.navigationController.toolbarHidden = YES;
    
    if ([self.teamsAR count] == 2) {
        self.addTeamBT.enabled = NO;
    }else{
        self.addTeamBT.enabled = YES;
    }
    self.roundsCounterTI.text = [NSNumber numberWithInt:[self.tournamentMO.hasRounds count]].stringValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    self.tourneyPhotoIV.clipsToBounds = YES;
    self.tourneyPhotoIV.layer.cornerRadius = 8.0;
    self.tourneyPhotoIV.layer.borderWidth = 2.0;
    self.tourneyPhotoIV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
    self.teamTV.clipsToBounds = YES;
    self.teamTV.layer.cornerRadius = 8.0;
    self.teamTV.layer.borderWidth = 2.0;
    self.teamTV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.teamTV.backgroundColor = [UIColor clearColor];
    
    self.playersTV.clipsToBounds = YES;
    self.playersTV.layer.cornerRadius = 8.0;
    self.playersTV.layer.borderWidth = 2.0;
    self.playersTV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.playersTV.backgroundColor = [UIColor clearColor];
    
    // Do any additional setup after loading the view.
    self.teamsAR = [[NSMutableArray alloc] init];
    self.playersAR = [[NSMutableArray alloc] init];
        self.selectedPlayerNS = [[NSMutableDictionary alloc] init];
    
    [self loadData];
    self.playerChange = NO;
//    self.gDriveUtil = [[GDriveUtils alloc] init:self];
    
}

- (void)keyboardWillShow:(NSNotification*)notification{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/*-------------------
 Actions
 --------------------*/

- (IBAction)backToHome:(id)sender {
}

- (IBAction)editTourneyPhoto:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
/*-------------------
 Save & Load
 --------------------*/
- (void)save {
//    NSManagedObjectContext *managedObjectContext;
    
    self.tournamentMO.tournamentName = self.tournamentTI.text;
    self.tournamentMO.icon = self.tourneyPicData;
    self.tournamentMO.status = @"pending";
    self.tournamentMO.internetPlay = [NSNumber numberWithBool:NO];
    self.tournamentMO.admin = self.myself.email;
    NSDate *today = [NSDate date];
    self.tournamentMO.creation_date = today;
    self.tournamentMO.id_of_Tournament = [NSString stringWithFormat:@"%@%@%@",self.tournamentTI.text,@"_",today];
    
    //first clear all players
    NSSet *set2 = [self.tournamentMO hasPlayers];
    [self.tournamentMO removeHasPlayers:set2];
    
    //then add selected
    self.playersAR = [self.selectedPlayerNS allValues];
    for (int i = 0; i < [self.playersAR count]; i++) {
        [self.tournamentMO addHasPlayersObject:self.playersAR[i]];
    }
    //reset all rounds to pending if they exist when player change was made (for edit mode)
    if (self.playerChange) {
        for (Round *round in self.tournamentMO.hasRounds) {
            round.status = @"pending";
        }
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theTournamentContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)loadData {
    if (self.tournamentMO == nil) {//new tournament
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tournament" inManagedObjectContext:managedObjectContext];
//        self.tournamentMO = [[Tournament alloc] initWithEntity:entity insertIntoManagedObjectContext:self.theContext];
        self.tournamentMO = [NSEntityDescription insertNewObjectForEntityForName:@"Tournament" inManagedObjectContext:self.theTournamentContext];
        self.isNewTour = YES;
    }else{
        //Editing Tour
        self.isNewTour = NO;
        self.addTourneyBT.title = @"Update";
        self.title = @"Editing Tournament";
        [self.tournamentTI setText:self.tournamentMO.tournamentName];//   [NSString stringWithFormat:@"%@", [self.tourMO valueForKey:@"tournamentName"]]];
        self.tourneyPicData = self.tournamentMO.icon;
        self.tourneyPhotoIV.image = [UIImage imageWithData:self.tourneyPicData];
        //fetch teams
        self.teamsAR = [[self.tournamentMO.hasTeams allObjects] mutableCopy];
        for (PlayerInTourney *player in self.tournamentMO.hasPlayers) {
            [self.selectedPlayerNS setObject:player forKey:player.email];
        }
    }
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.myself = appDelegate.myselfMO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    fetchRequest.includesSubentities = NO;
    NSManagedObjectContext *friendFetchContext = [self managedObjectContext];
    self.friendsAR = [[friendFetchContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self.friendsAR addObject:self.myself];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"friendName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.friendsAR = [self.friendsAR sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    [self.playersTV reloadData];
}
/*-------------------
 Helpers
 --------------------*/

/*-------------------
 Alerts
 --------------------*/

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
        if (tableView == self.playersTV){
            Friend *friend = [self.friendsAR objectAtIndex:indexPath.row];
            if ([self.selectedPlayerNS valueForKey:friend.email] == nil) {
                PlayerInTourney *player = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerInTourney" inManagedObjectContext:self.theTournamentContext];
                player.friendName = friend.friendName;
                player.email = friend.email;
                player.photo = friend.photo;
                player.handicap = friend.handicap;
                [self.selectedPlayerNS setObject:player forKey:friend.email];
                self.selectedPlayerMO = player;
                [self performSegueWithIdentifier:@"teamSelect" sender:self];
            }else{
                //unselect
                [self.selectedPlayerNS removeObjectForKey:friend.email];
                [self.playersTV reloadData];
            }
            self.playerChange = YES;
        }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.teamTV) {
        return [self.teamsAR count];
    }else if (tableView == self.playersTV){
        return [self.friendsAR count];
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (tableView == self.teamTV) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"teamCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        // Configure the cell...
        Team *team = [self.teamsAR objectAtIndex:indexPath.row];
        cell.textLabel.text = team.teamName;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:mainFont size:15];
        NSData *teamPicture = team.teamImage;
        UIImage *photo = [UIImage imageWithData:teamPicture];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.imageView.image = photo;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.layer.cornerRadius = 8.0;
        cell.imageView.layer.borderWidth = 1.0;
        cell.imageView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    else if (tableView == self.playersTV){
        cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell" forIndexPath:indexPath];
        Friend *player = [self.friendsAR objectAtIndex:indexPath.row];
        if ([self.selectedPlayerNS valueForKey:player.email] == nil) {
            cell.accessoryType = nil;//UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        PlayerInTourney *player1 = [self.selectedPlayerNS objectForKey:player.email];
        NSString *detlabelText = player.handicap.stringValue;
        if (player1 != nil) { //From existing tournament
            if (player1.team == nil) {
                detlabelText = detlabelText;
            }else{
                detlabelText = [NSString stringWithFormat:@"%@%@%@", detlabelText, @" - ", player1.team];
            }
        }
        
        cell.textLabel.text = player.friendName;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:mainFont size:15];
        cell.detailTextLabel.text = detlabelText;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        UIImage *photo = [UIImage imageWithData:player.photo];
        cell.imageView.image = photo;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.layer.cornerRadius = 2.0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
     if (tableView == self.teamTV){
         return YES;
     }else{
         return NO;
     }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (tableView == self.teamTV){
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            [self.theTournamentContext deleteObject:(Team *)self.teamsAR[indexPath.row]];
            //            [self.tourMO removeHasTeamsObject:self.teamsAR[indexPath.row]];//relationship
            [self.teamsAR removeObjectAtIndex: [indexPath row]];
            [self.teamTV reloadData];
            
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

/*-------------------
 PickerViews
 --------------------*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = [UIImage imageNamed:@"tourney.jpg"];
    selectedImage = [CoreDataUtil scaleImage:selectedImage withFactor:0.8];
    selectedImage = info[UIImagePickerControllerEditedImage];
    self.tourneyPhotoIV.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.tourneyPicData = UIImageJPEGRepresentation(selectedImage, 1);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
/*-------------------
 Functions
 --------------------*/
+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}
/*-------------------
 Exits
 --------------------*/

- (IBAction)unwindToNewTourney:(UIStoryboardSegue *)segue {
    NSObject *obj = [segue sourceViewController];
    if([segue.identifier isEqualToString:@"teamAddExit"]){
        TeamViewController *addTeamViewController = [segue sourceViewController];
        Team *newTeam = addTeamViewController.teamMO;
        if (self.teamsAR != nil && newTeam != nil) {
            [self.teamsAR addObject:newTeam];
            [self.tournamentMO addHasTeamsObject:newTeam];//relationship
            if (self.teamsAR.count > 0) {
                [self.teamTV reloadData];
            }
        }
    }else if([segue.identifier isEqualToString:@"teamSelectExit"]){
        [self.playersTV reloadData];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    BOOL retVal = YES;
    if (sender == self.addTourneyBT) {
        if ([self.selectedPlayerNS count] == 0 || [self.tournamentMO.hasRounds count] == 0) {
            [UIObjects showAlert:@"Missing data" message:@"Please select at least one Player and Add at least one Round" tag:9];
            retVal = NO;
        }else if([self.tournamentTI.text isEqualToString:@""]){
            [UIObjects showAlert:@"Missing data" message:@"Please enter a Tournament name" tag:9];
            retVal = NO;
        }else if([self.selectedPlayerNS count] > 8){
            #ifdef LITEVERSION
            [UIObjects showAlert:@"Lite Version" message:@"The lite version of this app allows only 8 players per tournament. Please Upgrade to the Full version for unlimited access!" tag:10];
            retVal = NO;
            #endif
        }
    }
    return retVal;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if(sender == self.cancelBT){
        [self cancel];
    }else if ([[segue identifier] isEqualToString:@"teamCreate"]) {
        TeamViewController *teamCreate = (TeamViewController *)[segue destinationViewController];
        teamCreate.theTournamentContext = self.theTournamentContext;
    }else if ([[segue identifier] isEqualToString:@"teamSelect"]) {
        PlayerTeamSelectViewController *popupVC;
        popupVC = segue.destinationViewController;
        popupVC.teamsAR = self.teamsAR;
        popupVC.playerMO = self.selectedPlayerMO;
        popupVC.playerTable = self.playersTV;
        [AddTourneyViewController setPresentationStyleForSelfController:self presentingController:self.popupVC];
    }else if ([[segue identifier] isEqualToString:@"ToRoundSelection"]){
        TourneyInstanceViewController *tournament = (TourneyInstanceViewController *)[segue destinationViewController];
        tournament.tournamentMO = self.tournamentMO;
        tournament.isInUpdate = !self.isNewTour;
        tournament.theTournamentContext = self.theTournamentContext;	
    }else if (sender == self.addTourneyBT) {
        [self save];
    }
}

- (void)cancel {
    if (self.isNewTour) {
//        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        [self.theTournamentContext deleteObject:self.tournamentMO];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
