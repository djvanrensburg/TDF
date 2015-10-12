//
//  PlayerTeamSelectViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/30.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "Team.h"
#import "PlayerTeamSelectViewController.h"
#import "Constants.h"
#import <CoreData/CoreData.h>
@interface PlayerTeamSelectViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *TeamsPV;
@property (weak, nonatomic) IBOutlet UITextField *handicapTI;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIM;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLB;
//@property TourneyTeam *teamTourneyMO;
@end

@implementation PlayerTeamSelectViewController
/*-------------------
 Initiators
 --------------------*/
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backgroundIM.clipsToBounds = YES;
    self.backgroundIM.layer.cornerRadius = 8.0;
    self.backgroundIM.layer.borderWidth = 2.0;
    self.backgroundIM.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    self.playerNameLB.text = self.playerMO.friendName;
    if ([self.teamsAR count] > 0) {
        Team *team = (Team *)[self.teamsAR objectAtIndex:0];
//        self.playerMO.isOfTeam = team;
        self.playerMO.team = team.teamName;
    }
    
    self.handicapTI.text = self.playerMO.handicap.stringValue;
}
/*-------------------
 Actions
 --------------------*/
- (IBAction)OKBT:(id)sender {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.playerMO.adjustedHC = [f numberFromString:self.handicapTI.text];
    [self.playerTable reloadData];
    [self dismissViewControllerAnimated:YES completion:Nil];
}
/*-------------------
 Save & Load
 --------------------*/

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
    return (int)self.teamsAR.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.teamsAR[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Team *team = (Team *)[self.teamsAR objectAtIndex:row];
    self.playerMO.team = team.teamName;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    //    label.backgroundColor = [UIColor lightGrayColor];
    //    label.textColor = [UIColor whiteColor];
    //    label.font = [UIFont fontWithName:@"Kohinoor Devanagari Medium" size:15];
    //    label.text = self.compArr[row];
    
    Team *team = self.teamsAR[row];
    UILabel *pickerViewLabel = (id)view;
    
    pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, -5.0f,
                                                               [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = team.teamName;
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

@end
