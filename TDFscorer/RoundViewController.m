//
//  RoundViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/16.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "RoundViewController.h"
#import <CoreData/CoreData.h>
#import "CompViewController.h"
#import "CourseBase.h"
#import "CourseViewController.h"
#import "Constants.h"
#import "CoreDataUtil.h"
#import "Hole.h"
#import "UIObjects.h"

@interface RoundViewController ()
//@property (strong) NSMutableArray *competitionsAR;
@property (weak, nonatomic) IBOutlet UITableView *competitionsTV;
@property (weak, nonatomic) IBOutlet UITextField *roundNumTI;
@property (weak, nonatomic) IBOutlet UIDatePicker *teeTimePV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRoundBT;
@property (weak, nonatomic) IBOutlet UIPickerView *coursePV;
@property NSMutableArray *courseAR;
@property NSDate *teeTime;
@property (weak, nonatomic) IBOutlet UISwitch *assembled;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBut;
@property CourseBase *courseMO;
@property NSManagedObjectContext *fetchCoursesContext;
@end

@implementation RoundViewController
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.assembled setOn:[self.roundMO.status isEqualToString:@"assembled"]];
    if (!self.assembled.isOn) {
        [self.assembled setEnabled:NO];
    }
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    // Do any additional setup after loading the view.
    self.competitionsTV.clipsToBounds = YES;
    self.competitionsTV.layer.cornerRadius = 8.0;
    self.competitionsTV.layer.borderWidth = 2.0;
    self.competitionsTV.layer.borderColor = [UIColor colorWithRed:0.31 green:0.86 blue:0.31 alpha:1.0].CGColor;
    self.competitionsTV.backgroundColor = [UIColor clearColor];
    
    self.competitionsAR = [[NSMutableArray alloc] init];
    [self.teeTimePV setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    //    [self.teeTimePV setValue:[UIFont fontWithName:@"Kohinoor Devanagari Medium" size:15] forUndefinedKey:@"font"];
    SEL selector = NSSelectorFromString( @"setHighlightsToday:" );
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature : [UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.teeTimePV];
    [self loadData];
    
}
/*-------------------
 Actions
 --------------------*/
- (IBAction)getTeeTime:(id)sender {
    self.teeTime = [self.teeTimePV date];
}

- (IBAction)toggleAssembled:(id)sender {
    if (!self.assembled.isOn) {
        [self.assembled setEnabled:NO];
//        self.roundMO.status = @"pending";
    }
}

/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    // Fetch the devices from persistent data store
    int index = 0;
    self.fetchCoursesContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CourseBase"];
//    [fetchRequest setPredicate:predicate];
    fetchRequest.includesSubentities = NO;
    self.courseAR = [[self.fetchCoursesContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.roundNumTI.text = self.roundNumber.stringValue;
    if (self.roundMO != nil) {
        self.teeTimePV.date = self.roundMO.teeTime;
        self.competitionsAR = [self.roundMO.hasComp allObjects].mutableCopy;
        for (Course *course in self.courseAR) {
            if ([course.courseName isEqualToString:self.roundMO.isOfCourse.courseName]) {
                self.courseMO = course;
                break;
            }
            index++;
        }
        [self.coursePV selectRow:index inComponent:0 animated:YES];
        self.saveBut.title = @"Update";
        self.inUpdateMode = YES;
    }else{
        self.inUpdateMode = NO;
    }
}

- (void)add {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (!self.inUpdateMode) {//new
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Round" inManagedObjectContext:managedObjectContext];
//        self.roundMO = [[Round alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

        self.roundMO = [NSEntityDescription insertNewObjectForEntityForName:@"Round" inManagedObjectContext:self.theTournamentContext];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *roundNum = [f numberFromString:self.roundNumTI.text];
        self.roundMO.number = roundNum;
        self.roundMO.status = @"pending";
    }
    if (self.teeTime != nil) {
        self.roundMO.teeTime = self.teeTime;
    }else{
        self.roundMO.teeTime = [NSDate date];
    }
    if (!self.assembled.isOn) {
        self.roundMO.status = @"pending";
    }
    //clear the round before adding comps
//    [self.roundMO removeHasComp:[self.roundMO hasComp]];
//    if (self.inUpdateMode) {
//        [managedObjectContext deleteObject:self.roundMO.isOfCourse];
//    }
    for (int i = 0; i < [self.competitionsAR count]; i++) {
        [self.roundMO addHasCompObject:self.competitionsAR[i]];//relationship
    }
    if (self.courseMO != nil) {
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
//        Course *course = [[Course alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

        Course *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.theTournamentContext];
//        NSDictionary *courseBaseDC = [self.courseMO toDictionary:NO];
//        NSManagedObjectContext *tempContext = [self managedObjectContext];
//        [course populateFromDictionary:courseBaseDC context:self.theTournamentContext];
        NSDictionary *attributes = [[NSEntityDescription entityForName:@"CourseBase" inManagedObjectContext:self.theTournamentContext] attributesByName];
        for (NSString *attr in attributes) {
            [course setValue:[self.courseMO valueForKey:attr] forKey:attr];
        }
        NSDictionary *holeAttr = [[NSEntityDescription entityForName:@"Hole" inManagedObjectContext:self.theTournamentContext] attributesByName];;
        for (Hole *h in self.courseMO.consistOf) {
            Hole *courseInRound_hole = [NSEntityDescription insertNewObjectForEntityForName:@"Hole" inManagedObjectContext:self.theTournamentContext];
            //copy values for holes
            for (NSString *attr in holeAttr) {
                [courseInRound_hole setValue:[h valueForKey:attr] forKey:attr];
            }
            [course addConsistOfObject:courseInRound_hole];
        }
        
        self.roundMO.isOfCourse = course;
    }else if([self.courseAR count] > 0){//default the course to first one in list
        self.courseMO = (CourseBase *)self.courseAR[0];

//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
//        Course *course = [[Course alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

        Course *course = [NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.theTournamentContext];
        NSDictionary *attributes = [[NSEntityDescription entityForName:@"CourseBase" inManagedObjectContext:self.theTournamentContext] attributesByName];
        for (NSString *attr in attributes) {
            [course setValue:[self.courseMO valueForKey:attr] forKey:attr];
        }
        NSDictionary *holeAttr = [[NSEntityDescription entityForName:@"Hole" inManagedObjectContext:self.theTournamentContext] attributesByName];;
        for (Hole *h in self.courseMO.consistOf) {
            Hole *courseInRound_hole = [NSEntityDescription insertNewObjectForEntityForName:@"Hole" inManagedObjectContext:self.theTournamentContext];
            //copy values for holes
            for (NSString *attr in holeAttr) {
                [courseInRound_hole setValue:[h valueForKey:attr] forKey:attr];
            }
            [course addConsistOfObject:courseInRound_hole];
        }

        self.roundMO.isOfCourse = course;
    }else{
        //error
    }
//    //update
//    if ( self.inUpdateMode) {
//        NSError *error = nil;
//        // Save the object to persistent store
//        if (![managedObjectContext save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }
//    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.competitionsAR count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        Competition *comp = [self.competitionsAR objectAtIndex:indexPath.row];
        [self.theTournamentContext deleteObject:comp];
        [self.competitionsAR removeObjectAtIndex: [indexPath row]];
        [self.competitionsTV reloadData];
//        NSError *error = nil;
//        if (![managedObjectContext save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"compCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellStyleSubtitle;
    //    // Configure the cell...
    Competition *comp = [self.competitionsAR objectAtIndex:indexPath.row];
    cell.textLabel.text = comp.compType;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:mainFont size:13];
    cell.backgroundColor = [UIColor clearColor];
    if (comp.isTeamComp.boolValue) {
        cell.detailTextLabel.text = @"Team Comp.";
    }else{
        cell.detailTextLabel.text = @"Individual Comp.";
    }
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont fontWithName:mainFont size:10];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];

    return cell;
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
    return self.courseAR.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.courseAR[row];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UIView *pickerViewEntry = [[UIView alloc] initWithFrame:CGRectMake(37.0f, -5.0f, [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
    
    UILabel *pickerViewLabel = (id)view;
    
    pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(27.0f, 0.0f,
                                                               [pickerView rowSizeForComponent:component].width - 25.0f, [pickerView rowSizeForComponent:component].height)];
    CourseBase *courseMO = (CourseBase *)self.courseAR[row];
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = courseMO.courseName;
    pickerViewLabel.font = [UIFont fontWithName:mainFont size:15];
    pickerViewLabel.textColor = [UIColor whiteColor];
    
    [pickerViewEntry addSubview:pickerViewLabel];
    
    UIImageView *pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 20.0f)];
    pickerImageView.image = [UIImage imageWithData:courseMO.picture];
    pickerImageView.clipsToBounds = YES;
    pickerImageView.layer.cornerRadius = 2.0;
    pickerImageView.layer.borderWidth = 1.0;
    pickerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button addTarget:self action:@selector(editCourse:) forControlEvents:UIControlEventAllEvents];
//    [button setTitle:@"Edit" forState:UIControlStateNormal];
//    button.frame = pickerViewLabel.frame;
//    button.tag = row;
    [pickerViewEntry addSubview:pickerImageView];
    return pickerViewEntry;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.courseMO = (CourseBase *)[self.courseAR objectAtIndex:row];
}

/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (sender == self.addRoundBT) {
        BOOL hasIndComp = NO;
        for (Competition *comp in self.competitionsAR) {
            if (!comp.isTeamComp.boolValue) {
                hasIndComp = YES;
                break;
            }
        }
        if (!hasIndComp) {
            [UIObjects showAlert:@"Missing data" message:@"Please add an individual competition format" tag:1];
            return NO;
        }else if ([self.competitionsAR count] > 0 ) {
            return YES;
        }else if( [self.courseAR count] == 0){
            [UIObjects showAlert:@"Missing data" message:@"Please add a course" tag:1];
            return NO;
        }else{
            UIAlertView *message2 = [[UIAlertView alloc] initWithTitle:@"Missing data"
                                                               message:@"The Round was not created, please add at least one competition format"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            [message2 show];
            return NO;
        }
    }else if ([identifier isEqualToString:@"editCourse"]){
        if ([self.courseAR count] == 0) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }

}

- (IBAction)unwindToRound:(UIStoryboardSegue *)segue{
    NSObject *obj = [segue sourceViewController];

    if ([obj isKindOfClass:[CompViewController class]]) {
        CompViewController *addCompViewController = [segue sourceViewController];
            [self.competitionsAR addObject:addCompViewController.compMO];
            if (self.competitionsAR.count > 0) {
                [self.competitionsTV reloadData];
            }
    } else if([obj isKindOfClass:[CourseViewController class]]){
        [self loadData];
        [self.coursePV reloadAllComponents];
    }
}

- (void)cancel {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addCompBT"]){
        CompViewController *compVC = (CompViewController *)[segue destinationViewController];
        compVC.tourneyMO = self.tourneyMO;
        compVC.theTournamentContext = self.theTournamentContext;
    }else if (sender == self.addRoundBT) {
            [self add];
    }else if ([segue.identifier isEqualToString:@"editCourse"]){
        CourseViewController *courseView = (CourseViewController *)[segue destinationViewController];
        if (self.courseMO == nil) {
            courseView.courseMO = self.courseAR[0];
        }else{
            courseView.courseMO = self.courseMO;
        }
        courseView.theCourseContext = self.fetchCoursesContext;
    }else if ([segue.identifier isEqualToString:@"addCourse"]){
        CourseViewController *courseView = (CourseViewController *)[segue destinationViewController];
        courseView.theCourseContext = [self managedObjectContext];
    }
}

@end
