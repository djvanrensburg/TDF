//
//  TourneyInstanceViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "TourneyInstanceViewController.h"
#import <CoreData/CoreData.h>
#import "TeamViewController.h"
#import "RoundViewController.h"
#import "Round.h"
#import "Course.h"
#import "Team.h"
#import "Friend.h"
#import "Self.h"
#import "PlayerInTourney.h"

#import "PlayerTeamSelectViewController.h"
#import "AssembleRoundViewController.h"
#import "Constants.h"
#import "CoreDataUtil.h"
#import "UIObjects.h"

@interface TourneyInstanceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *roundTV;
@property (weak, nonatomic) IBOutlet UITableView *teamsTV;
@property (weak, nonatomic) IBOutlet UITableView *playersTV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveInstBT;
@property (weak, nonatomic) IBOutlet UITextField *idTI;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRoundBT;
@property (weak, nonatomic) IBOutlet UIButton *addRoundBT;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPlayerBT;
@property (weak, nonatomic) IBOutlet UIButton *addPlayerBT;
@property NSMutableDictionary *selectedPlayerNS;
@property (weak, nonatomic) IBOutlet UIPickerView *scoringTypePV;

@property Round *selectedRoundMO;
@property Self *myself;
//@property (strong, nonatomic) IBOutlet UIView *scoringTypePV;
@property NSMutableDictionary *scoringTypeDC;
@property NSString *scoringType;

//@property (strong, nonatomic) IBOutlet UIButton *fakeShowTeamBT;
//@property (weak, nonatomic) IBOutlet UIButton *testBT;

//@property NSMutableArray *friendsAR;
@end

@implementation TourneyInstanceViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationController.toolbarHidden = NO;
    [self.roundTV reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isInUpdate) {
        self.saveInstBT.title = @"Update";
    }
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
        
    self.roundTV.clipsToBounds = YES;
    self.roundTV.layer.cornerRadius = 8.0;
    self.roundTV.layer.borderWidth = 2.0;
    self.roundTV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.roundTV.backgroundColor = [UIColor clearColor];
    
    self.playersTV.clipsToBounds = YES;
    self.playersTV.layer.cornerRadius = 8.0;
    self.playersTV.layer.borderWidth = 2.0;
    self.playersTV.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.playersTV.backgroundColor = [UIColor clearColor];
    self.playersTV.scrollEnabled = YES;
    
    self.roundsAR = [[NSMutableArray alloc] init];
    
    //    self.teamsAR = [[NSArray alloc] init];
//    self.selectedPlayerNS = [[NSMutableDictionary alloc] init];
    
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self loadData];
}

/*-------------------
 Actions
 --------------------*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    int index = 0;
    // Fetch the data from persistent data store
    self.teamsAR = [self.tournamentMO.hasTeams allObjects];
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if ([self.tournamentMO.hasRounds count] > 0) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"teeTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.roundsAR = [self.tournamentMO.hasRounds allObjects].mutableCopy;
        self.roundsAR = [self.roundsAR sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
        for (PlayerInTourney *player in self.tournamentMO.hasPlayers) {
            [self.selectedPlayerNS setObject:player forKey:player.email];
        }
    }
    self.scoringTypeDC = [Constants getScoringTypes];
    
    if (self.tournamentMO.scoringType != nil) {
        for (NSString *obj in self.scoringTypeDC) {
            if ([[self.scoringTypeDC objectForKey:obj] isEqualToString:self.tournamentMO.scoringType]) {
                break;
            }
            index++;
        }
        [self.scoringTypePV selectRow:index inComponent:0 animated:YES];
    }else{
        self.tournamentMO.scoringType = [self.scoringTypeDC objectForKey:@"0"];
    }
}

- (void)save {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    self.tourneyInstMO.status = @"pending";
//    self.tourneyInstMO.internetPlay = [NSNumber numberWithBool:NO];
//    self.tourneyInstMO.admin = self.myself.email;
//    NSDate *today = [NSDate date];
//    self.tourneyInstMO.creation_date = today;
//    self.tournamentMO.scoringType = self.scoringType;
    //rounds
    
    //first clear all rounds
    NSSet *set = [self.tournamentMO hasRounds];
    [self.tournamentMO removeHasRounds:set];
    //then add selected
    for (int i = 0; i < [self.roundsAR count]; i++) {
        [self.tournamentMO addHasRoundsObject:self.roundsAR[i]];
    }
    
    //players
    
//    //first clear all players
//    NSSet *set2 = [self.tourneyInstMO hasPlayers];
//    [self.tourneyInstMO removeHasPlayers:set2];
//    
//    //then add selected
//    self.playersAR = [self.selectedPlayerNS allValues];
//    for (int i = 0; i < [self.playersAR count]; i++) {
//        [self.tourneyInstMO addHasPlayersObject:self.playersAR[i]];
//    }
//    //instance to tour
//    [self.tourMO addHasYearInstancesObject:self.tourneyInstMO];
    
//    NSError *error = nil;
//    // Save the object to persistent store
//    if (![managedObjectContext save:&error]) {
//        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        return 30;
    }else{
        return 40;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.roundTV) {
        return [self.roundsAR count];
        //    }else if (tableView == self.teamsTV){
        //        return [self.teamsAR count];
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (tableView == self.roundTV){
//        self.selectedRoundMO = self.roundsAR[indexPath.row];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.roundTV) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roundsCell" forIndexPath:indexPath];
        //        cell.selectionStyle = UITableViewCellStyleSubtitle;
        //    // Configure the cell...
        Round *round = [self.roundsAR objectAtIndex:indexPath.row];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy hh:mm"];
        Course *course = round.isOfCourse;
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", round.number.stringValue,@". ",course.courseName ];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:mainFont size:15];
        cell.detailTextLabel.text = [dateFormat stringFromDate:round.teeTime];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.font = [UIFont fontWithName:mainFont size:12];
        if (![round.status isEqualToString:@"pending"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        return cell;
    }else{
        return nil;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.roundTV) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            Round *round = [self.roundsAR objectAtIndex:indexPath.row];
            [self.theTournamentContext deleteObject:round];
            [self.roundsAR removeObjectAtIndex: [indexPath row]];
            [self.roundTV reloadData];
//            NSError *errorMO = nil;
//            // Save the object to persistent store
//            if (![managedObjectContext save:&errorMO]) {
//                NSLog(@"Can't Save! %@ %@", errorMO, [errorMO localizedDescription]);
//            }
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*-------------------
 PickerViews
 --------------------*/
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)self.scoringTypeDC.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.tournamentMO.scoringType = [self.scoringTypeDC objectForKey:[NSString stringWithFormat: @"%ld", (long)row]];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *pickerViewLabel = (id)view;
    pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, -5.0f,
                                                               [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = [self.scoringTypeDC objectForKey:[NSString stringWithFormat: @"%ld", (long)row]];
    pickerViewLabel.font = [UIFont fontWithName:mainFont size:15];
    pickerViewLabel.textColor = [UIColor whiteColor];
    return pickerViewLabel;
}
/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    BOOL retval = YES;
    if ([identifier isEqualToString:@"tourneyInstSave"]){
        if ([self.roundsAR count] > 0) {
            [self save];
            retval = YES;
        }else{
            UIAlertView *message2 = [[UIAlertView alloc] initWithTitle:@"Missing data"
                                                               message:@"Please add at least one round"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [message2 show];
            retval = NO;
        }
    }else if (sender == self.addRoundBT){
        if ([self.roundsAR count] > 0) {
            #ifdef LITEVERSION
            [UIObjects showAlert:@"Lite Version" message:@"The lite version of this app allows only 1 round per tournament. Please Upgrade to the Full version for unlimited access!" tag:1];
                retval = NO;
            #endif
        }
    }else{
    }
    return retval;
}

- (IBAction)unwindToTourneyInst:(UIStoryboardSegue *)segue{
    NSObject *obj = [segue sourceViewController];
    
    if ([obj isKindOfClass:[RoundViewController class]]) {
        RoundViewController *addRoundViewController = [segue sourceViewController];
        if (self.roundsAR != nil && addRoundViewController.roundMO != nil && !addRoundViewController.inUpdateMode) {
            [self.roundsAR addObject:addRoundViewController.roundMO];
            
            if (self.roundsAR.count > 0) {
                [self.roundTV reloadData];
            }
        }
    }else if ([obj isKindOfClass:[AssembleRoundViewController class]]){
        [self.roundTV reloadData];
    }
}

- (void)cancel {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    [managedObjectContext deleteObject:self.tournamentMO];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"tourneyInstExit"]) {
        [self cancel];
    }else if([segue.identifier isEqualToString:@"showRound"]){
        RoundViewController *round = (RoundViewController *)[segue destinationViewController];
        self.selectedRoundMO = self.roundsAR[self.roundTV.indexPathForSelectedRow.row];
        round.tourneyMO = self.tournamentMO;
        round.roundMO = self.selectedRoundMO;
        round.roundNumber = self.selectedRoundMO.number;
        round.theTournamentContext = self.theTournamentContext;
    } else if(sender == self.addRoundBT){
        RoundViewController *round = (RoundViewController *)[segue destinationViewController];
        round.roundNumber = [NSNumber numberWithInt:self.roundsAR.count+1];
        round.tourneyMO = self.tournamentMO;
        round.theTournamentContext = self.theTournamentContext;
    }
}





@end
