//
//  OpenTourneysTableViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/11.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "OpenTourneysTableViewController.h"
#import <CoreData/CoreData.h>

#import "Tournament.h"
#import "RoundsInPlayViewController.h"

//static NSString *const kKeychainItemName = @"Tour de Force";
//static NSString *const kClientID = @"975845056051-vhv2p9oep2eci5huci5m5vobh0sd5p8e.apps.googleusercontent.com";
//static NSString *const kClientSecret = @"kzBkiq10JQzxl1gfPVtkgl7P";

@interface OpenTourneysTableViewController ()
@property NSMutableArray *myOpenTourneysArr;
@property Tournament *selectedTourneyMO;
@property (strong, nonatomic) IBOutlet UITableView *InstancesTV;
@property NSManagedObjectContext *fetchOpenTournamentContext;
//@property (nonatomic, retain) GTLServiceDrive *driveService;
@end

@implementation OpenTourneysTableViewController

/*-------------------
 Initiators
 --------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    [self loaddata];
}

- (void) viewDidAppear:(BOOL)animated{
    self.navigationController.toolbarHidden = YES;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

/*-------------------
 Save & Load
 --------------------*/
- (void)loaddata{
    self.fetchOpenTournamentContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tournament"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status<>'completed'"];
//    [fetchRequest setPredicate:predicate];
    self.myOpenTourneysArr = [[self.fetchOpenTournamentContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creation_date" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.myOpenTourneysArr = [[self.myOpenTourneysArr sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

/*-------------------
 Helpers
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
    return [self.myOpenTourneysArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tourneyCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    // Configure the cell...
    Tournament *selectedInstanceMO = [self.myOpenTourneysArr objectAtIndex:indexPath.row];
    cell.textLabel.text = selectedInstanceMO.tournamentName;
    NSData *tourneyPicture = selectedInstanceMO.icon;
    UIImage *photo = [UIImage imageWithData:tourneyPicture];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = photo;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.borderWidth = 2.0;
    cell.imageView.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedTourneyMO = [self.myOpenTourneysArr objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showRounds" sender:self];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.fetchOpenTournamentContext deleteObject:self.myOpenTourneysArr[indexPath.row]];
        [self.myOpenTourneysArr removeObject:self.myOpenTourneysArr[indexPath.row]];
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.fetchOpenTournamentContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    [self.InstancesTV reloadData];
}

/*-------------------
 Exits
 --------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RoundsInPlayViewController *rounds = (RoundsInPlayViewController *)[segue destinationViewController];
    rounds.tourneyMO = self.selectedTourneyMO;
    rounds.theTournamentContext = [self managedObjectContext];
}

@end
