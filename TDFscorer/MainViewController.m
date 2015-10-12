//
//  MainViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/09.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "MainViewController.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "TourneyList.h"
#import "GDriveUtils.h"
#import "CoreDataUtil.h"
#import "UIObjects.h"
#import "Self.h"
@interface MainViewController ()
@property (strong) Self *myProfile;
@property (weak, nonatomic) IBOutlet UITextField *myHandicap;
@property (weak, nonatomic) IBOutlet UITextField *myTournament;
@property (weak, nonatomic) IBOutlet UITextField *myName;

@property (weak, nonatomic) IBOutlet UITextField *myNumTours;
@property (weak, nonatomic) IBOutlet UITextField *myRanking;
@property NSData *myPicture;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarTB;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tourneyBarBT;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leagueBarBT;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playBarBT;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gamesBarBT;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLB;
@property (weak, nonatomic) IBOutlet UILabel *subheadingLB;
@property GDriveUtils *gDriveUtil;
@property Tournament *directImportedTourney;
@property AppDelegate *appDelegate;
@property NSManagedObjectContext *tempTournamentContext;
@property NSMutableArray *tourneys;
@end

@implementation MainViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

- (NSManagedObjectContext *)managedObjectContext{
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
//    [UIObjects showAlert:@"open from mail" message:@"In appear" tag:1];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    self.photo.clipsToBounds = YES;
    self.photo.layer.cornerRadius = 8.0;
    self.photo.layer.borderWidth = 2.0;
    self.photo.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
    UIColor *color = [UIColor lightGrayColor];
    self.myName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"no Profile yet" attributes:@{NSForegroundColorAttributeName: color}];
    self.myHandicap.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"n.a." attributes:@{NSForegroundColorAttributeName: color}];
    self.myTournament.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"no Favourite Tournament selected" attributes:@{NSForegroundColorAttributeName: color}];
    self.myNumTours.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0" attributes:@{NSForegroundColorAttributeName: color}];
    self.myRanking.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0" attributes:@{NSForegroundColorAttributeName: color}];
    
//    [UIObjects showAlert:@"open from mail" message:@"In load" tag:1];

//    self.appDelegate.importFileID = @"0B2zL96F6wjcXZXhRTU9xRzJqcWc";
    if (self.appDelegate.importFileID != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Tournament Import"
                                           message: @"Are you sure you want to import the tournament from Google Drive?"
                                          delegate: self
                                 cancelButtonTitle: @"Cancel"
                                 otherButtonTitles: @"Import", nil];
        alert.tag = 77;
        [alert show];
        
//        self.gDriveUtil = [[GDriveUtils alloc]init:self];
//
//        //Sync from gdrive
//        if ([self.gDriveUtil isAuthorized]){
//            self.tempTournamentContext = [self managedObjectContext];
//            //first get the tourneys
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tournament"];
//            self.tourneys = [[self.tempTournamentContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//            [self.gDriveUtil loadFileFromGdrive:self.appDelegate.importFileID managedObjectContext:self.tempTournamentContext suppressAlert:NO];
//        }else{
//            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
//            [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
//        }
    }
}
/*-------------------
 Actions
 --------------------*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 77) {
        if (buttonIndex == 1) {
            self.gDriveUtil = [[GDriveUtils alloc]init:self];
            
            //Sync from gdrive
            if ([self.gDriveUtil isAuthorized]){
                self.tempTournamentContext = [self managedObjectContext];
                //first get the tourneys
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tournament"];
                self.tourneys = [[self.tempTournamentContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                [self.gDriveUtil loadFileFromGdrive:self.appDelegate.importFileID managedObjectContext:self.tempTournamentContext suppressAlert:NO];
            }else{
                // Not yet authorized, request authorization and push the login UI onto the navigation stack.
                [self.navigationController pushViewController:[self.gDriveUtil createAuthController] animated:YES];
            }

        }
    }
}
/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Self"];
    NSMutableArray *myProfileArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (myProfileArr.count > 0) {
        self.myProfile = [myProfileArr objectAtIndex:0];
        [self.myName setText:[NSString stringWithFormat:@"%@", [self.myProfile valueForKey:@"friendName"]]];
        if (self.myProfile.favTournament != nil) {
            [self.myTournament setText:[NSString stringWithFormat:@"%@", [self.myProfile valueForKey:@"favTournament"]]];
        }
        NSNumber *hc = [self.myProfile valueForKey:@"handicap"];
        [self.myHandicap setText:[NSString stringWithFormat:@"%@", hc.stringValue]];
        NSNumber *ranking = [self.myProfile valueForKey:@"rankingPoints"];
        [self.myRanking setText:[NSString stringWithFormat:@"%@", ranking.stringValue]];
        NSNumber *numTours = [self.myProfile valueForKey:@"numberOfTourneys"];
        [self.myNumTours setText:[NSString stringWithFormat:@"%@", numTours.stringValue]];
        self.myPicture = [self.myProfile valueForKey:@"photo"];
        if (self.myPicture != nil) {
            self.photo.image = [UIImage imageWithData:self.myPicture];
        }
        
        
        self.appDelegate.myselfMO = self.myProfile;
        self.tourneyBarBT.enabled = YES;
        self.leagueBarBT.enabled = YES;
        self.playBarBT.enabled = YES;
        self.gamesBarBT.enabled = YES;
    }else{
        self.tourneyBarBT.enabled = NO;
        self.leagueBarBT.enabled = NO;
        self.playBarBT.enabled = NO;
        self.gamesBarBT.enabled = NO;
    }
}
/*-------------------
 Helpers
 --------------------*/
-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    self.directImportedTourney = (Tournament *)anyObject;
//    [CoreDataUtil assignPicturesFromLib:self.directImportedTourney managedContext:[self managedObjectContext]];
    [self performSegueWithIdentifier:@"directImportedTourney" sender:self];
}
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

/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue {
    [self.navigationController.navigationBar clearsContextBeforeDrawing];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TourneyList *tourViewController = (TourneyList *) [segue destinationViewController];

    if ([[segue identifier] isEqualToString:@"showGames"]) {
        tourViewController.toGames = YES;
    }else if ([segue.identifier isEqualToString:@"directImportedTourney"]){
        tourViewController.directImmportedTourney = self.directImportedTourney;
        tourViewController.theTournamentContext = self.tempTournamentContext;
        tourViewController.tourneys = self.tourneys;
    }
}


@end
