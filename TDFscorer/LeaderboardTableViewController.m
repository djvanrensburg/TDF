//
//  LeaderboardTableViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "LeaderboardTableViewController.h"
#import "PlayerInTourney.h"
#import "PlayerUIView.h"
#import "Constants.h"
#import <CoreData/CoreData.h>
#import "CoreDataUtil.h"
#import "Tournament.h"
#import "Round.h"
#import "Group.h"
#import "PlayerInGroup.h"
#import "GDriveUtils.h"

@interface LeaderboardTableViewController ()
@property NSMutableArray *allPlayersAR;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *syncBT;
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property NSMutableDictionary *playerHoleInd;
//@property GDriveUtils *gDriveUtil;
//@property Tournament *gDriveTourneyMO;
@end

@implementation LeaderboardTableViewController
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
-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.gDriveUtil = [[GDriveUtils alloc] init:self];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    [self loaddata];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}


/*-------------------
 Actions
 --------------------*/


/*-------------------
 Save & Load
 --------------------*/
    - (void) loaddata{
        self.allPlayersAR = [[NSMutableArray alloc] init];
        //sort according to score
        NSSortDescriptor *sortDescriptor;
        if ([self.tourneyMO.scoringType isEqualToString:@"Strokeplay"]) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPoints" ascending:YES];
        }else{
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPoints" ascending:NO];
        }
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.allPlayersAR = [self.tourneyMO.hasPlayers sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
        self.playerHoleInd = [[NSMutableDictionary alloc]init];
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
        return [self.allPlayersAR count] + 1;
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayersCell" forIndexPath:indexPath];
    //delete all subviews first
    for (UIView *sub in cell.subviews) {
        [sub removeFromSuperview];
    }
         float xPos = 0;
         float width = 20;
         cell.backgroundColor = [UIColor clearColor];
         if (indexPath.row == 0) {
             UILabel *scoreLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60 - 70, 0, 60, 80)];
             scoreLab.text = @"Total";
             scoreLab.font = [UIFont fontWithName:mainFont size:14];
             scoreLab.textAlignment = NSTextAlignmentCenter;
             scoreLab.textColor = [UIColor whiteColor];
             [cell addSubview:scoreLab];
             
             UILabel *pointsLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 0, 70, 80)];
             pointsLab.text = @"Net/Points";
             pointsLab.font = [UIFont fontWithName:mainFont size:14];
             pointsLab.textAlignment = NSTextAlignmentCenter;
             pointsLab.textColor = [UIColor lightGrayColor];
             [cell addSubview:pointsLab];
         }else{
             PlayerInTourney *player = self.allPlayersAR[indexPath.row - 1];
             // Configure the cell...
             UIView *playerView =[[PlayerUIView alloc] initWithFrame:CGRectMake(10,5,160,50)];
             
             UILabel *positionLab =[[UILabel alloc] initWithFrame:CGRectMake(xPos, 0, width, 50)];
             positionLab.textColor = [UIColor whiteColor];
             positionLab.text = [NSNumber numberWithInt:indexPath.row].stringValue;
             positionLab.textAlignment = NSTextAlignmentLeft;
             positionLab.font = [UIFont fontWithName:mainFont size:20];
             [playerView addSubview:positionLab];
             
             // player name
             UILabel *playerName =[[UILabel alloc] initWithFrame:CGRectMake(55 + width, 0, 100, 20)];
             playerName.textColor = [UIColor whiteColor];
             playerName.text = player.friendName;
             playerName.textAlignment = NSTextAlignmentCenter;
             playerName.font = [UIFont fontWithName:mainFont size:10];
             //team name
             UILabel *playerTeam =[[UILabel alloc] initWithFrame:CGRectMake(55 + width, 18, 100, 20)];
             playerTeam.textColor = [UIColor lightGrayColor];
             playerTeam.text = player.team;
             playerTeam.textAlignment = NSTextAlignmentCenter;
             playerTeam.font = [UIFont fontWithName:mainFont size:10];
             //scores
             UILabel *playerScores =[[UILabel alloc] initWithFrame:CGRectMake(55 + width, 33, 100, 20)];
             playerScores.textColor = [UIColor lightGrayColor];
             playerScores.text = [self getRoundTotals:player.email];
             playerScores.textAlignment = NSTextAlignmentCenter;
             playerScores.font = [UIFont fontWithName:mainFont size:8];

             UIImageView *playerPhoto =[[UIImageView alloc] initWithFrame:CGRectMake(width,0,50,50)];
             playerPhoto.image=[UIImage imageWithData:player.photo];
             playerPhoto.layer.cornerRadius = playerPhoto.frame.size.width / 2;
             playerPhoto.clipsToBounds = YES;
             playerPhoto.layer.borderWidth = 2.0;
             playerPhoto.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
             
             [playerView addSubview:playerPhoto];
             [playerView addSubview:playerName];
             [playerView addSubview:playerTeam];
             [playerView addSubview:playerScores];
             
             [cell addSubview:playerView];
             
             UILabel *scoreLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60 - 70, 0, 60, 80)];
             scoreLab.text = player.totalScore.stringValue;
             scoreLab.font = [UIFont fontWithName:mainFont size:20];
             scoreLab.textColor = [UIColor whiteColor];
             scoreLab.textAlignment = NSTextAlignmentCenter;
             [cell addSubview:scoreLab];
             //add hole at indicator
             UILabel *holeAt = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60 - 35, 15, 18, 15)];
             NSNumber * holeInd = [self.playerHoleInd objectForKey:player.email];
             holeAt.text = holeInd.stringValue;
             holeAt.font = [UIFont fontWithName:mainFont size:12];
             holeAt.textColor = [UIColor lightGrayColor];
             holeAt.textAlignment = NSTextAlignmentCenter;
             holeAt.layer.borderColor = [UIColor lightGrayColor].CGColor;
             holeAt.layer.borderWidth = 1.0;
             [cell addSubview:holeAt];
             
             UILabel *pointsLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 0, 70, 80)];
             pointsLab.text = player.totalPoints.stringValue;
             pointsLab.font = [UIFont fontWithName:mainFont size:20];
             pointsLab.textColor = [UIColor lightGrayColor];
             pointsLab.textAlignment = NSTextAlignmentCenter;
             [cell addSubview:pointsLab];
         }
         
     return cell;
     }

/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Functions
 --------------------*/
- (NSString *) getRoundTotals:(NSString *)email{
    NSString *roundsAsString = @" - ";
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@",email];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedRounds = [self.tourneyMO.hasRounds sortedArrayUsingDescriptors:sortDescriptors];
    
    for (Round *round in sortedRounds) {
        for (Group *group in round.hasGroups) {
            NSArray *pl = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects];
            if ([pl count]>0) {
                PlayerInGroup *player = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects][0];
                roundsAsString = [NSString stringWithFormat:@"%@%@%@",roundsAsString,player.totalScore.stringValue,@" - "];
                //hole at
                if ([round.status isEqualToString:@"in progress"]) {
//                    group.hole
                    [self.playerHoleInd setObject:group.holeInd forKey:player.email];
                }
                break;
            }
        }
    }
    return roundsAsString;
}

/*-------------------
 Exits
 --------------------*/



@end
