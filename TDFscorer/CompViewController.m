//
//  CompViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "CompViewController.h"
#import <CoreData/CoreData.h>
#import "Constants.h"

@interface CompViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *compPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addCompBT;
//@property (weak, nonatomic) IBOutlet UIButton *addCompBT;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *addCompBT;
@property NSArray *compAR;
//@property NSManagedObject *compMO;

@property (weak, nonatomic) IBOutlet UISwitch *teamCompTG;
@property (weak, nonatomic) IBOutlet UISwitch *hcTo0ToG;
@property NSString *compType;
@end

@implementation CompViewController
/*-------------------
 Initiators
 --------------------*/
//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    // Do any additional setup after loading the view.
    self.compAR = [Constants getCompetitionTypes:self.tourneyMO.scoringType];
    self.compType = self.compAR[0];
}
/*-------------------
 Actions
 --------------------*/

/*-------------------
 Save & Load
 --------------------*/
- (void)add {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Competition" inManagedObjectContext:managedObjectContext];
//    self.compMO = [[Competition alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

    self.compMO = [NSEntityDescription insertNewObjectForEntityForName:@"Competition" inManagedObjectContext:self.theTournamentContext];
    self.compMO.compType = self.compType;
    //    [self.compMO  setValue:self.compType forKey:@"compType"];
    NSNumber *isHcTo0 = [NSNumber numberWithBool:self.hcTo0ToG.isOn];
    self.compMO.isHighHCtoZero = isHcTo0;
    //    [self.compMO  setValue:isHcTo0 forKey:@"isHighHCtoZero"];
    NSNumber *isTeam = [NSNumber numberWithBool:self.teamCompTG.isOn];
    self.compMO.isTeamComp = isTeam;
    if ([self.compType containsString:@"One-on-One"]) {
        self.compMO.isOneOnOne = [NSNumber numberWithBool:YES];
    }
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
    return (int)self.compAR.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.compType = self.compAR[row];
    if ([self.compType containsString:@"Combined"] || [self.compType containsString:@"Betterball"] || [self.compType containsString:@"One-on-One"]) {
        [self.teamCompTG setOn:YES];
    }else{
        [self.teamCompTG setOn:NO];
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerViewLabel = (id)view;
    
    pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, -5.0f,
                                                               [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
//    NSString *rowStr = [NSString stringWithFormat: @"%ld", (long)row];
    pickerViewLabel.text = self.compAR[row];
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

- (void)cancel {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.addCompBT) {
        [self cancel];
    }else{
        [self add];
    }
}

@end
