//
//  FriendTableViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/07.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "FriendTableViewController.h"
#import "AddFriendViewController.h"
#import <CoreData/CoreData.h>
#import "Friend.h"

@interface FriendTableViewController ()

@property (strong) NSMutableArray *friendsAR;
@property NSData *myPicture;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendBT;
@property (strong, nonatomic) IBOutlet UITableView *firendsTV;
//@property NSMutableDictionary *selectedPlayerMD;
@end

@implementation FriendTableViewController
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
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    //    self.selectedPlayerMD = [[NSMutableDictionary alloc] init];
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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    fetchRequest.includesSubentities = NO;
    self.friendsAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (self.friendsAR.count > 0) {
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
    return [self.friendsAR count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    NSManagedObject *friend = [self.friendsAR objectAtIndex:indexPath.row];
    //    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [friend valueForKey:@"friendName"]]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [friend valueForKey:@"friendName"]];
    NSNumber *hc = [friend valueForKey:@"handicap"];
    cell.detailTextLabel.text = hc.stringValue;
    self.myPicture = [friend valueForKey:@"photo"];
    UIImage *photo = [UIImage imageWithData:self.myPicture];
    cell.imageView.image = photo;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.borderWidth = 1.0;
    cell.imageView.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];

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
        NSManagedObject *friend = [self.friendsAR objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:friend];
        [self.friendsAR removeObjectAtIndex: [indexPath row]];
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
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/


- (IBAction)unwindToFriendsList:(UIStoryboardSegue *)segue {

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    AddFriendViewController *addFriendViewController = (AddFriendViewController *)[segue destinationViewController];
    if (sender != self.addFriendBT) {
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        addFriendViewController.friendMO = self.friendsAR[[myIndexPath row]];
    }
}

@end
