//
//  CoursesTableViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/21.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "CoursesTableViewController.h"
#import <CoreData/CoreData.h>
#import "CourseBase.h"
#import "CourseViewController.h"
#import "Constants.h"

@interface CoursesTableViewController ()

@property NSMutableArray *coursesAR;
@property (strong, nonatomic) IBOutlet UITableView *coursesTV;

@end

@implementation CoursesTableViewController

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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
}

/*-------------------
 Actions
 --------------------*/

/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CourseBase"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"usedInRound.@count == 0"];//[NSPredicate predicateWithFormat:@"usedInRound = nil"];
//    [fetchRequest setPredicate:predicate];
    fetchRequest.includesSubentities = NO;
    self.coursesAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (self.coursesAR.count > 0) {
        [self.tableView reloadData];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.coursesAR count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"coursesCell" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    CourseBase *course = [self.coursesAR objectAtIndex:indexPath.row];
    cell.textLabel.text = course.courseName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:mainFont size:15];
    cell.detailTextLabel.text = course.province;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
//    cell.textLabel.font = [UIFont fontWithName:mainFont size:15];
    
    UIImage *photo = [UIImage imageWithData:course.picture];
    cell.imageView.image = photo;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.borderWidth = 1.0;
    cell.imageView.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        CourseBase *course = [self.coursesAR objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:course];
        [self.coursesAR removeObjectAtIndex: [indexPath row]];
        [self.tableView reloadData];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Exits
 --------------------*/
- (IBAction)unwindToCourseList:(UIStoryboardSegue *)segue {

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"editCourse"]) {
        CourseViewController *courseView = (CourseViewController *)[segue destinationViewController];
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];

        courseView.courseMO = self.coursesAR[myIndexPath.row];
    }
}


@end
