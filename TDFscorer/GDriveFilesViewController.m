//
//  GDriveFilesViewController.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/09/26.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//
/* This class renders the ui for selecting a gDrive file for importing into the app
   When the user selects the file to import, it returns to TourneyList.h for processing*/

#import "GDriveFilesViewController.h"
#import "Constants.h"
#import "CoreDataUtil.h"
#import "GDriveUtils.h"
@interface GDriveFilesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *filesTV;
@property NSMutableArray *theTDFfiles;
@property GDriveUtils *gDriveUtil;

@end

@implementation GDriveFilesViewController

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.importedTourneyMO = nil;
        self.gDriveUtil = [[GDriveUtils alloc]init:self];
    self.theTDFfiles = [[NSMutableArray alloc]init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    // Do any additional setup after loading the view.
    self.filesTV.clipsToBounds = YES;
    self.filesTV.layer.cornerRadius = 8.0;
    self.filesTV.layer.borderWidth = 2.0;
    self.filesTV.layer.borderColor = [UIColor colorWithRed:0.31 green:0.86 blue:0.31 alpha:1.0].CGColor;
    self.filesTV.backgroundColor = [UIColor clearColor];
    
    //ensure only .tdf files
    for (GTLDriveFile *file in self.gdriveFileList.items) {
        if ([file.title hasSuffix:@".tdf"]) {
            [self.theTDFfiles addObject:file];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sync:(id)sender {
    NSIndexPath *myIndexPath = [self.filesTV indexPathForSelectedRow];
    GTLDriveFile *file = self.theTDFfiles[myIndexPath.row];
    if ([self.gDriveUtil isAuthorized]){
        [self.gDriveUtil loadFileFromGdrive:file.identifier managedObjectContext:self.theTournamentContext suppressAlert:NO];
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    self.importedTourneyMO = (Tournament *)anyObject;
    [CoreDataUtil assignPicturesFromLib:self.importedTourneyMO managedContext:self.theTournamentContext];
    [self performSegueWithIdentifier:@"importedTourney" sender:self];
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
    return [self.theTDFfiles count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gDriveFiles" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellStyleSubtitle;
    //    // Configure the cell...
    GTLDriveFile *file = self.theTDFfiles[indexPath.row];
    cell.textLabel.text = file.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:mainFont size:13];
    cell.backgroundColor = [UIColor clearColor];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy hh:mm"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",@"Created by:",file.ownerNames[0]];
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

@end
