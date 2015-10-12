//
//  ScoringViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "ScoringViewController.h"
#import "PlayerInGroup.h"
#import "PlayerInTourney.h"
#import "Friend.h"
#import <CoreData/CoreData.h>
#import "Self.h"
#import "Group.h"
#import "Round.h"
#import "Hole.h"
#import "ScoringUISlider.h"

#import "Tournament.h"
//#import "ScrocardTableViewController.h"
#import "ScorecardViewController.h"
#import "Competition.h"
#import "Constants.h"
#import "UIObjects.h"
#import "AppDelegate.h"
#import "GDriveUtils.h"
#import "ScoreCard.h"
const float pictureSize = 50;

@interface ScoringViewController ()

@property Self *myself;
@property (weak, nonatomic) IBOutlet UILabel *parLL;
@property (weak, nonatomic) IBOutlet UILabel *holeLL;
@property Group *myGroup;
@property (weak, nonatomic) IBOutlet UILabel *strokeLL;
@property (weak, nonatomic) IBOutlet UITableView *playerTV;
@property NSNumber *holeInd;
@property NSArray *holesAR;
@property GTLQueryDrive *saveHoleQuery;
@property NSMutableArray *sortedPlayers;
@property (weak, nonatomic) IBOutlet UILabel *CompetitionLB;
@property (weak, nonatomic) IBOutlet UIWebView *leaderboardWV;
@property (weak, nonatomic) IBOutlet UIWebView *teamLeaderboardWV;
@property NSPredicate *predicateHoleNr;
@property (weak, nonatomic) IBOutlet UIProgressView *progressVie;
@property (weak, nonatomic) IBOutlet UIButton *previousBT;
@property (weak, nonatomic) IBOutlet UIButton *nextBT;
@property GDriveUtils *gDriveUtil;
@property Tournament *driveTourney;
@property NSMutableSet *groupsForDeletion;
@property NSMutableSet *groupsForInsert;
@end

@implementation ScoringViewController

/*-------------------
 Initiators
 --------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    self.gDriveUtil = [[GDriveUtils alloc] init:self];
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    self.playerTV.backgroundColor = [UIColor clearColor];
    [self loaddata];
    self.title = [NSString stringWithFormat:@"%@%@", @"Round ", self.roundMO.number.stringValue];

    NSString *compText;
    for (Competition *comp in self.roundMO.hasComp) {
        if (compText != nil) {
            compText = [NSString stringWithFormat:@"%@%@%@",compText,@"; ",comp.compType];
        }else{
            compText = comp.compType;
        }
    }
    self.CompetitionLB.text = compText;
    self.CompetitionLB.textAlignment = NSTextAlignmentCenter;

    [self updateHoleInfo:YES];
    self.leaderboardWV.backgroundColor = [UIColor clearColor];
    [self updateLeaderBoard];
    
}

- (void) viewWillAppear:(BOOL)animated{
}

- (void) viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    //if iphone 4 don't show leaderboard banner as there is no space on the screen
    if (self.view.frame.size.height <= 480) {
        [self.leaderboardWV removeFromSuperview];
        [self.teamLeaderboardWV removeFromSuperview];
    }
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
 Actions
 --------------------*/
- (IBAction)clearHole:(id)sender {
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: @"Clear Hole"
                                       message: @"Are you sure want to clear the scoring for this hole?"
                                      delegate: self
                             cancelButtonTitle: @"Cancel"
                             otherButtonTitles: @"OK", nil];
    alert.tag = 9;
    [alert show];
}

- (IBAction)nextHole:(id)sender {
    [self goToNextHole];
}

- (IBAction)previousHole:(id)sender {
    self.holeInd = [NSNumber numberWithInt:self.holeInd.intValue - 1];
    [self updateHoleInfo:YES];
    [self.playerTV reloadData];
}

- (void)goToNextHole{
    if (self.holeInd.intValue == 18) {
        self.holeInd = [NSNumber numberWithInt:1];
    }else{
        self.holeInd = [NSNumber numberWithInt:self.holeInd.intValue + 1];
    }
    [self updateHoleInfo:YES];
    [self.playerTV reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //navigate to scorecard
    [self performSegueWithIdentifier:@"navigateToSC" sender:self];
}

- (IBAction)saveScore:(id)sender {
    [self savedata];
}

-(void)sliderAction:(id)sender
{
    ScoringUISlider *slider = (ScoringUISlider*)sender;
    
    int value = slider.value;
    
    slider.holeMO.score = [NSNumber numberWithInt:value];
    //get the uiview to update
    NSIndexPath *ind = [NSIndexPath indexPathForRow:slider.tag inSection:0] ;
    UITableViewCell *cell = [self.playerTV cellForRowAtIndexPath:ind];
    for (UIView * sub in cell.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)sub;
            if (lab.tag == 1) {
                //scoring view
                lab.text = [NSNumber numberWithInt:value].stringValue;
            }else if (lab.tag == 2){
                lab.text = [self calculateScore:slider.holeMO player:slider.playerMO].stringValue;
            }else if (lab.tag == 3){
                lab.text = [self getSemanticalScore:slider.holeMO.score.intValue par:slider.holeMO.par.intValue];
            }
        }
    }
}
/*-------------------
 Save & Load
 --------------------*/
-(void) savedata{
    [self calculateCompScores];
    //set totals players
    for (PlayerInGroup * player in self.myGroup.hasPlayers) {
        [self totalScores:player];
        player.hasScoreCard.holeInd = [NSNumber numberWithInt:( self.holeInd.intValue + 1)];
    }
    //save score and move to next hole
//    BOOL successfullSave = YES;
    [self updateLeaderBoard]; //we need this to happen before save
    if (self.internetPlay) {
        [self syncWithGdrive];
    }else{
        [self savedata_core];
    }
}

-(void) savedata_core{
    if (self.driveTourney != nil) {
        [self.theTournamentContext deleteObject:self.driveTourney];
    }

    // save to core data
    self.roundMO.numHolesCompleted = [NSNumber numberWithInt:0];
    PlayerInGroup *randomPlayer = [self.myGroup.hasPlayers allObjects][0];
    Scorecard *scorecard = randomPlayer.hasScoreCard;
    for (Hole *hole in scorecard.consistOf) {
        if (hole.score.intValue > 0) {
            self.roundMO.numHolesCompleted = [NSNumber numberWithInt:self.roundMO.numHolesCompleted.intValue + 1];
        }
    }
    if (self.roundMO.numHolesCompleted.intValue == 18) {
        self.roundMO.status = @"completed";
    }else{
        self.roundMO.status = @"in progress";
    }
    self.roundMO.isPlayedInTourney.status = @"in progress";
//    [self updateLeaderBoard]; //we need this to happen before save
//    NSManagedObjectContext *context = [self managedObjectContext];
    
    self.myGroup.holeInd = self.holeInd;

    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theTournamentContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    //        [self viewDidLoad];
    [self updateHoleInfo:NO];
    [self.playerTV reloadData];
    [self goToNextHole];
}

- (void) loaddata {
    self.sortedPlayers = [[NSMutableArray alloc]init];

    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.myself = appDelegate.myselfMO;
    //Find myself in the set of players
    for (Group *group in self.roundMO.hasGroups) {
        for (PlayerInGroup *player in group.hasPlayers) {
            if ([player.email isEqualToString:self.myself.email]){
                //get the group I play in
                self.myGroup = group;
                self.holeInd = player.hasScoreCard.holeInd;
                break;
            }
        }
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.sortedPlayers = [self.myGroup.hasPlayers sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
}

- (void) syncWithGdrive {
    //take Gdrive Instance and migrate the obects to phone instance where needed. Then garbage collect the Drive instance and its context
    GTMOAuth2ViewControllerTouch *authController;
    if ([self.gDriveUtil isAuthorized]){
        [self.gDriveUtil loadFileFromGdrive:self.roundMO.isPlayedInTourney.gDriveFileID managedObjectContext:self.theTournamentContext suppressAlert:YES];
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:authController = [self.gDriveUtil createAuthController] animated:YES];
    }
}

- (void) migrateOtherGroups:(Group *)driveGroup{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupid == %@",driveGroup.groupid];
    NSArray *group = [self.roundMO.hasGroups allObjects];
    group = [group filteredArrayUsingPredicate:predicate];
    [self.groupsForDeletion addObject:(Group *)group[0]];
//    [self.roundMO removeHasGroupsObject:group[0]];
    [self.groupsForInsert addObject:driveGroup];
//    [self.roundMO addHasGroupsObject:driveGroup];
}


-(void) totalScores:(PlayerInGroup *)groupPlayer{
    groupPlayer.totalPoints = [NSNumber numberWithInt:0];
    groupPlayer.totalScore = [NSNumber numberWithInt:0];
    for (Hole *hole in groupPlayer.hasScoreCard.consistOf){
        groupPlayer.totalScore = [NSNumber numberWithInt:hole.score.intValue + groupPlayer.totalScore.intValue];
        groupPlayer.totalPoints = [NSNumber numberWithInt:hole.result.intValue + groupPlayer.totalPoints.intValue];
    }

}

- (void) scorePlayerInTourney:(PlayerInGroup *)groupPlayer totalPoint:(NSNumber *)totalRoundPoints totalScore:(NSNumber *)totalRoundScore{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@",groupPlayer.email];
    PlayerInTourney *tourneyPlayer = [[self.roundMO.isPlayedInTourney.hasPlayers filteredSetUsingPredicate:predicate] allObjects][0];

    tourneyPlayer.totalScore = [NSNumber numberWithInt:totalRoundScore.intValue + tourneyPlayer.totalScore.intValue];
    tourneyPlayer.totalPoints = [NSNumber numberWithInt:totalRoundPoints.intValue + tourneyPlayer.totalPoints.intValue];
}

- (int) reconcileHoles:(Group *) driveGroup {
    __block BOOL emptyDriveHole = NO;
    __block BOOL holeMismatch = NO;
    for (PlayerInGroup *player in driveGroup.hasPlayers) {
        NSString *filter1 = [NSString stringWithFormat:@"%@%@",@"holeNumber =",self.holeInd.stringValue];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:filter1];
        NSArray *holeAR = [[player.hasScoreCard.consistOf filteredSetUsingPredicate:predicate1] allObjects];
        Hole *driveHole = holeAR[0];
        
        //get this player's current score
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"email == %@",player.email];
        NSSet *playerSet = [self.myGroup.hasPlayers filteredSetUsingPredicate:predicate2];
        PlayerInGroup *appPlayer = [playerSet allObjects][0];
        
        NSArray *curholeAR = [[appPlayer.hasScoreCard.consistOf filteredSetUsingPredicate:predicate1] allObjects];
        Hole *currentHole = curholeAR[0];
        
        NSLog(@"Hole on gDrive's score: %@", driveHole.score.stringValue);
        NSLog(@"Hole on phone's score: %@", currentHole.score.stringValue);
        if (driveHole.score.intValue == 0) {
            emptyDriveHole = YES; //this means nobody in my 4ball has submitted a score for this hole yet
        }
        if (driveHole.score.intValue != currentHole.score.intValue) {
            //hole doesn't match
            holeMismatch = YES;
        }
        
        driveHole.score = [NSNumber numberWithInt:currentHole.score.intValue];
    }
    
    if (emptyDriveHole) {
        return 1;
    }else if(holeMismatch){
        return 2;
    }else{
        return 3;
    }
}

/*-------------------
 Helpers
 --------------------*/
-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    self.groupsForDeletion = [[NSMutableSet alloc] init];
    self.groupsForInsert = [[NSMutableSet alloc]init];
    if ([crud isEqualToString:@"r"]) {
        int reconcileRet = 0;
        self.driveTourney = (Tournament *)anyObject;
//        @try {
            for (Round *round in self.driveTourney.hasRounds) {
                if (round.number.intValue == self.roundMO.number.intValue) {
                    for (Group *driveGroup in round.hasGroups) {
                        if (driveGroup.groupid == self.myGroup.groupid) {
                            //is holeInd's hole already populated? If it is, does it match my scoring for everyone?
                            reconcileRet = [self reconcileHoles:driveGroup];
                            //                    break;
                        }else{
                            //migrate other groups
                            [self migrateOtherGroups:driveGroup];
                        }
                    }
                }
            }
        [self.roundMO removeHasGroups:self.groupsForDeletion];
        [self.roundMO addHasGroups:self.groupsForInsert];
        
        if (reconcileRet == 1) {
            //emptyDriveHole
            // Save myScore
            NSDictionary *tourInstNS = [self.roundMO.isPlayedInTourney toDictionary :YES];
           [self.gDriveUtil saveToGDrive:self.roundMO.isPlayedInTourney.id_of_Tournament tourInst:tourInstNS fileID:self.roundMO.isPlayedInTourney.gDriveFileID players:nil suppressAlert:YES doShare:NO tourName:self.roundMO.isPlayedInTourney.tournamentName];
        }else if (reconcileRet == 2){
            //holeMismatch
            //raise Alert with option to overwrite
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle: @"The scoring for this hole doesn't match the scoring submitted by another player"
                                               message: @"Do you want to Overwrite the save score?"
                                              delegate: nil
                                     cancelButtonTitle: @"Cancel"
                                     otherButtonTitles: @"OK", nil];
            alert.tag = 1;
            [alert show];
        }
    }else{
        //Saving
        [self savedata_core];
    }
}

- (NSString *) getSemanticalScore:(int)score par:(int)par{
    NSString *theString;
    int diff = score - par;
    switch (diff) {
        case -3:
            theString = @"Albetros";
            break;
        case -2:
            theString = @"Eagle";
            break;
        case -1:
            theString = @"Birdie";
            break;
        case 0:
            theString = @"Par";
            break;
        case 1:
            theString = @"Bogey";
            break;
        case 2:
            theString = @"Double";
            break;
        default:
            theString = @"Other";
            break;
    }
    return theString;
}

-(void) updateHoleInfo:(BOOL)suppressAlert{
    NSString *filterHoleInd = [NSString stringWithFormat:@"%@%@",@"holeNumber=",self.holeInd.stringValue];
    self.predicateHoleNr = [NSPredicate predicateWithFormat:filterHoleInd];

    self.holeLL.text = [NSString stringWithFormat:@"%@%@", @"Hole ", self.holeInd.stringValue];
    self.progressVie.progress = self.holeInd.floatValue / 18.0;
    self.previousBT.enabled = self.holeInd.intValue == 1?NO:YES;
    self.nextBT.enabled = self.holeInd.intValue == 18?NO:YES;
    if (self.roundMO.numHolesCompleted.intValue == 18 && !suppressAlert) {
        [UIObjects showAlert:@"End of Round" message:@"Your round is complete! Hold iPhone horizontal to view full Scorecard" tag:1];
    }
}

-(void) updateTeamLeaderboard{
    PlayerInGroup *player1A, *player2A;
    PlayerInGroup *player1B, *player2B;
    NSString *leaderboard;
    NSString *result;

    for (Group *group in self.roundMO.hasGroups) {
        for (Competition *comp in self.roundMO.hasComp) {
            //get the two teams
            player1A = [group.hasPlayers allObjects][0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@",player1A.team];
            NSArray *otherPl = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects];
            player1A = [otherPl count]>0?otherPl[0]:nil;
            player2A = [otherPl count] == 2?otherPl[1]:nil;
            
            predicate = [NSPredicate predicateWithFormat:@"team != %@",player1A.team];
            otherPl = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects];
            player1B = [otherPl count]>0?otherPl[0]:nil;
            player2B = [otherPl count] == 2?otherPl[1]:nil;
            if ([comp.compType containsString:@"Combined"] || [comp.compType containsString:@"Betterball"]) {
                //Only need one Player from each team
                if (player2B == nil || player2A == nil || player1A == nil || player1B == nil) {
                    return;
                }
                NSNumber *teamAEndResult, *teamBEndResult;

                result = [self subUpdateTeamLead:player1A player2:player1B compType:comp.compType endRes1:&teamAEndResult endRes2:&teamBEndResult];

                if (leaderboard != nil) {
                    leaderboard = [NSString stringWithFormat:@"%@%@%@%@%@",leaderboard,@"&nbsp;Group ",group.groupid.stringValue,@": ",result];
                }else{
                    leaderboard = [NSString stringWithFormat:@"%@%@%@%@",@"Group ",group.groupid.stringValue,@": ",result];
                }
                
                player1A.teamPoints = teamAEndResult;
                player2A.teamPoints = teamAEndResult;
                player1B.teamPoints = teamBEndResult;
                player2B.teamPoints = teamBEndResult;

                break;
            }else if([comp.compType containsString:@"One-on-One"]){
                NSNumber *match1AEndResult, *match2AEndResult,*match1BEndResult, *match2BEndResult;

                PlayerInGroup *match1A, *match1B, *match2A, *match2B;
                
                if (player2A != nil && player2B) {
                    match1A = player1A.index.intValue < player2A.index.intValue?player1A:player2A;
                    match2A = player1A.index.intValue > player2A.index.intValue?player1A:player2A;
                    
                    match1B = player1B.index.intValue < player2B.index.intValue?player1B:player2B;
                    match2B = player1B.index.intValue > player2B.index.intValue?player1B:player2B;
                }else{
                    //For cases where only two players in group
                    match1A = player1A;
                    match1B = player1B;
                }
                
                result = [self subUpdateTeamLead:match1A player2:match1B compType:comp.compType endRes1:&match1AEndResult endRes2:&match1BEndResult];
                if (leaderboard != nil) {
                    leaderboard = [NSString stringWithFormat:@"%@%@%@%@%@",leaderboard,@"&nbsp;Group ",group.groupid.stringValue,@": ",result];
                }else{
                    leaderboard = [NSString stringWithFormat:@"%@%@%@%@",@"Group ",group.groupid.stringValue,@": ",result];
                }
                if (match2A != nil && match2B != nil) {
                    result = [self subUpdateTeamLead:match2A player2:match2B compType:comp.compType endRes1:&match2AEndResult endRes2:&match2BEndResult];
                    leaderboard = [NSString stringWithFormat:@"%@%@%@",leaderboard,@";&nbsp;",result];
                }
                
                player1A.teamPoints = match1AEndResult;
                player2A.teamPoints = match2AEndResult;
                player1B.teamPoints = match1BEndResult;
                player2B.teamPoints = match2BEndResult;
                
                break;
            }
        }
    }
    if (leaderboard == nil) {
        leaderboard = @"No leaderboard exists";
    }
    //create html
    leaderboard = [NSString stringWithFormat:@"%@%@%@",@"<html><body bgcolor=black><marquee direction=left scrollamount=3 behavior=scroll style=\"color: #ffffff; font-size: 11px; font-family: Arial;\">",leaderboard,@"</marquee></body></html>"];
    [self.teamLeaderboardWV loadHTMLString:leaderboard baseURL:nil];
}

- (NSString *) subUpdateTeamLead:(PlayerInGroup *)p1 player2:(PlayerInGroup *)p2 compType:(NSString *)compType endRes1:(NSNumber **)endResult1 endRes2:(NSNumber **)endResult2{
    NSString *result, *oneOnoneMatch, *subject;
    if ([compType containsString:@"Matchplay"]) {
        int teamTotal = 0;
        for (Hole *hole in p1.hasScoreCard.consistOf) {
            teamTotal = teamTotal + hole.teamScore.intValue;
        }
        if (teamTotal == 0) {
            oneOnoneMatch = [NSString stringWithFormat:@"%@%@%@%@",p1.friendName, @" vs. ",p2.friendName,@" is All Square"];
            result = [compType containsString:@"One-on-One"]?oneOnoneMatch :@"Teams are All Square";
            *endResult1 = [NSNumber numberWithFloat:0];
            *endResult2 = [NSNumber numberWithFloat:0];
        }else if (teamTotal < 0){
            teamTotal = teamTotal * -1;
            subject = [compType containsString:@"One-on-One"]?p2.friendName:p2.team;
            result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotal].stringValue,@" up"];
            *endResult1 = [NSNumber numberWithFloat:-teamTotal];
            *endResult2 = [NSNumber numberWithFloat:teamTotal];
        }else{
            subject = [compType containsString:@"One-on-One"]?p1.friendName:p1.team;
            result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotal].stringValue,@" up"];
            *endResult1 = [NSNumber numberWithFloat:teamTotal];
            *endResult2 = [NSNumber numberWithFloat:-teamTotal];
        }
    }else {
        int teamTotalA = 0;
        int teamTotalB = 0;
        
        for (Hole *hole in p1.hasScoreCard.consistOf) {
            teamTotalA = teamTotalA + hole.teamScore.intValue;
        }
        for (Hole *hole in p2.hasScoreCard.consistOf) {
            teamTotalB = teamTotalB + hole.teamScore.intValue;
        }
        if (teamTotalA == teamTotalB) {
            oneOnoneMatch = [NSString stringWithFormat:@"%@%@%@%@",p1.friendName, @" vs. ",p2.friendName,@" are Tied"];
            result = [compType containsString:@"One-on-One"]?oneOnoneMatch:@"Teams are Tied";
            *endResult1 = [NSNumber numberWithFloat:teamTotalA];
            *endResult2 = [NSNumber numberWithFloat:teamTotalB];
        }else if(teamTotalB > teamTotalA){
            if([compType containsString:@"Stableford"]){
                subject = [compType containsString:@"One-on-One"]?p2.friendName:p2.team;
                result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotalB - teamTotalA].stringValue,@" ahead"];
                *endResult1 = [NSNumber numberWithFloat:teamTotalA];
                *endResult2 = [NSNumber numberWithFloat:teamTotalB];
            }else{ //strokeplay
                subject = [compType containsString:@"One-on-One"]?p1.friendName:p1.team;
                result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotalB - teamTotalA].stringValue,@" ahead"];
                *endResult1 = [NSNumber numberWithFloat:teamTotalA];
                *endResult2 = [NSNumber numberWithFloat:teamTotalB];
            }
        }else{
            if([compType containsString:@"Stableford"]){
                subject = [compType containsString:@"One-on-One"]?p1.friendName:p1.team;
                result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotalA - teamTotalB].stringValue,@" ahead"];
                *endResult1 = [NSNumber numberWithFloat:teamTotalA];
                *endResult2 = [NSNumber numberWithFloat:teamTotalB];
            }else{ //strokeplay
                subject = [compType containsString:@"One-on-One"]?p2.friendName:p2.team;
                result = [NSString stringWithFormat:@"%@%@%@%@", subject,@" is ", [NSNumber numberWithInt:teamTotalA - teamTotalB].stringValue,@" ahead"];
                *endResult1 = [NSNumber numberWithFloat:teamTotalA];
                *endResult2 = [NSNumber numberWithFloat:teamTotalB];
            }
        }
    }

    return result;
}

-(void) updateLeaderBoard{
    NSMutableArray *allPlayers = [[NSMutableArray alloc] init];
    //Tally the Rounds
    
    //initialize totals
    for (PlayerInTourney *player in self.roundMO.isPlayedInTourney.hasPlayers) {
        player.totalScore = [NSNumber numberWithInt:0];
        player.totalPoints = [NSNumber numberWithInt:0];
    }

//    BOOL firstTime = YES;
    for (Round *round in self.roundMO.isPlayedInTourney.hasRounds) {
        for (Group *group in round.hasGroups) {
            for (PlayerInGroup *player in group.hasPlayers) {
                [self scorePlayerInTourney:player totalPoint:player.totalPoints totalScore:player.totalScore];
            }
        }
//        if (firstTime) {
//            firstTime = NO;
//        }
    }

    //sort according to score
    NSSortDescriptor *sortDescriptor;
    if ([self.CompetitionLB.text containsString:@"Strokeplay"] && [self.CompetitionLB.text containsString:@"Individual"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPoints" ascending:YES];
    }else{
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPoints" ascending:NO];
    }
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    allPlayers = [self.roundMO.isPlayedInTourney.hasPlayers sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    
    NSString *leaderboard;
    int ind = 0;
    for (PlayerInTourney *player in allPlayers) {
        if (player.totalPoints != nil) {
            ind = ind + 1;
            if (leaderboard != nil) {
                leaderboard = [NSString stringWithFormat:@"%@%d%@%@%@%@%@%@%@",leaderboard,ind,@":",player.friendName,@"&nbsp;",player.totalPoints.stringValue,@"(",player.totalScore,@")&nbsp;"];
            }else{
                leaderboard = [NSString stringWithFormat:@"%d%@%@%@%@%@%@%@",ind,@":",player.friendName,@"&nbsp;",player.totalPoints.stringValue,@"(",player.totalScore,@")&nbsp;"];
            }
        }
    }
    if (leaderboard == nil) {
        leaderboard = @"No leaderboard exists";
    }else{
        [self updateTeamLeaderboard];
    }
    //create html
    leaderboard = [NSString stringWithFormat:@"%@%@%@",@"<html><body bgcolor=black><marquee direction=left scrollamount=3 behavior=scroll style=\"color: #93DB18; font-size: 11px; font-family: Arial;\">",leaderboard,@"</marquee></body></html>"];
    [self.leaderboardWV loadHTMLString:leaderboard baseURL:nil];
}
/*-------------------
 Alerts
 --------------------*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            //Do Nothing
        }
        else if (buttonIndex == 1) {
            //OK - overwrite
            // Save myScore
            NSDictionary *tourInstNS = [self.roundMO.isPlayedInTourney toDictionary :YES];
            [self.gDriveUtil saveToGDrive:self.roundMO.isPlayedInTourney.id_of_Tournament tourInst:tourInstNS fileID:self.roundMO.isPlayedInTourney.gDriveFileID players:nil suppressAlert:YES doShare:NO tourName:self.roundMO.isPlayedInTourney.tournamentName];
        }
    }else if (alertView.tag == 9){
        //Clear hole confirm
        if (buttonIndex == 1) {
            for (PlayerInGroup *player in self.myGroup.hasPlayers) {
                Scorecard *scorecard = player.hasScoreCard;
                self.holesAR = [[scorecard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects];
                Hole *hole = self.holesAR[0];
                hole.score = [NSNumber numberWithInt:0];
                hole.result = [NSNumber numberWithInt:0];
            }
            [self.playerTV reloadData];
        }
    }
}
/*-------------------
 Others
 --------------------*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-------------------
 Functions
 --------------------*/
- (NSNumber *)calculateScore:(Hole *)theHole player:(PlayerInGroup *) thePlayer{
    //first calculate the individual's score
    for (Competition *comp in self.roundMO.hasComp){
        //first calculate the individual's score
        if (!comp.isTeamComp.boolValue) {
            //Stableford
            if ([comp.compType containsString:@"Stableford"]){// isEqualToString:IDV_SF_MP] || [comp.compType isEqualToString:IDV_SF]) {
                if (thePlayer.adjustedHC.intValue >= theHole.stroke.intValue) {
                    //this player strokes this hole
                    theHole.result = [NSNumber numberWithInt:theHole.par.intValue + 1 + 2 - theHole.score.intValue];
                }else{
                    theHole.result = [NSNumber numberWithInt:theHole.par.intValue + 2 - theHole.score.intValue];
                }
                theHole.result = theHole.result.intValue < 0?[NSNumber numberWithInt:0]:theHole.result;
                break;
                //Stroke PLay
            }else if([comp.compType containsString:@"Strokeplay"]){
                if (thePlayer.adjustedHC.intValue >= theHole.stroke.intValue) {
                    //this player strokes this hole
                    theHole.result = [NSNumber numberWithInt:theHole.score.intValue - 1];
                }else{
                    theHole.result = [NSNumber numberWithInt:theHole.score.intValue];
                }
                //now check that the upper limit wasn't exceeded
                if ([comp.compType containsString:@"max +2"] && theHole.result.intValue > 2 + theHole.par.intValue) {
                    theHole.result = [NSNumber numberWithInt:2 + theHole.par.intValue];
                }else if ([comp.compType containsString:@"max +3"] && theHole.result.intValue > 3 + theHole.par.intValue){
                    theHole.result = [NSNumber numberWithInt:3 + theHole.par.intValue];
                }else if ([comp.compType containsString:@"max +4"] && theHole.result.intValue > 4 + theHole.par.intValue){
                    theHole.result = [NSNumber numberWithInt:4 + theHole.par.intValue];
                }else if ([comp.compType containsString:@"max +5"] && theHole.result.intValue > 5 + theHole.par.intValue){
                    theHole.result = [NSNumber numberWithInt:5 + theHole.par.intValue];
                }
                break;
            }
        }
        //Now calculate the team's score
    }
    return theHole.result;
}

- (void) calculateCompScores{
    for (Competition *comp in self.roundMO.hasComp) {
        if (comp.isTeamComp.boolValue) {
            //get the two teams
            PlayerInGroup *player1A = self.sortedPlayers[0];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@",player1A.team];
            NSArray *otherPl = [self.sortedPlayers filteredArrayUsingPredicate:predicate];
            player1A = [otherPl count] > 0?otherPl[0]:nil;
            PlayerInGroup *player2A = [otherPl count] == 2?otherPl[1]:nil;
            
            predicate = [NSPredicate predicateWithFormat:@"team != %@",player1A.team];
            otherPl = [self.sortedPlayers filteredArrayUsingPredicate:predicate];
            PlayerInGroup *player1B = [otherPl count] > 0?otherPl[0]:nil;
            PlayerInGroup *player2B = [otherPl count] == 2?otherPl[1]:nil;
            
            if ([comp.compType containsString:@"Betterball"] || [comp.compType containsString:@"Combined"]) {
                //check
                if (player1A == nil || player1B == nil || player2A == nil || player2B == nil) {
                    //raise error
                    [UIObjects showAlert:@"Configuration Error" message:@"Unequal Teams, please correct" tag:1];
                    return;
                }
            }
            if ([comp.compType isEqualToString:TM_BB_SF]) {
                //Betterball Stableford
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSGreaterThanPredicateOperatorType combined:NO];//successfully tested
            }else if([comp.compType isEqualToString:TM_BB_SF_MP]){
                //Betterball Stableford Matchplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSGreaterThanPredicateOperatorType combined:NO];//successfully tested
            }else if( [comp.compType isEqualToString:TM_BB_SP]){
                //Betterball Strokeplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSLessThanPredicateOperatorType combined:NO];
            }else if ([comp.compType isEqualToString:TM_BB_SP_MP]){
                //Betterball Strokeplay Matchplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSLessThanPredicateOperatorType combined:NO];//successfully tested
            }else if ([comp.compType isEqualToString:TM_COM_SF]){
                //Combined Stableford
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSGreaterThanPredicateOperatorType combined:YES];//successfully tested
            }else if([comp.compType isEqualToString:TM_COM_SF_MP]){
                //Combined Stableford Matchplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSGreaterThanPredicateOperatorType combined:YES];//successfully tested
            }else if( [comp.compType isEqualToString:TM_COM_SP]){
                //Combined Strokeplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSLessThanPredicateOperatorType combined:YES];
            }else if ([comp.compType isEqualToString:TM_COM_SP_MP]){
                //Combined Strokeplay Matchplay
                [self getTeam_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSLessThanPredicateOperatorType combined:YES];
            }else if ([comp.compType isEqualToString:OO_SF]){
                //One-on-One Stableford
                [self getIndividual_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSGreaterThanPredicateOperatorType];
            }else if ([comp.compType isEqualToString:OO_SF_MP]){
                //One-on-One Stableford Matchplay
                [self getIndividual_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSGreaterThanPredicateOperatorType];
            }else if ([comp.compType isEqualToString:OO_SP]){
                //One-on-One Strokeplay
                [self getIndividual_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:NO operator:NSLessThanPredicateOperatorType];
            }else if ([comp.compType isEqualToString:OO_SP_MP]){
                //One-on-One Strokeplay Matchplay
                [self getIndividual_result:player1A player2A:player2A player1B:player1B player2B:player2B matchplay:YES operator:NSLessThanPredicateOperatorType];//successfully tested
            }
        }
    }
}

- (void) getIndividual_result:(PlayerInGroup *)player1A player2A:(PlayerInGroup *) player2A player1B:(PlayerInGroup *) player1B player2B:(PlayerInGroup *) player2B
            matchplay:(BOOL)isMatchplay operator:(NSPredicateOperatorType)operator{
    
    PlayerInGroup *match1A, *match1B, *match2A, *match2B;
    
    if (player2A != nil && player2B) {
        match1A = player1A.index.intValue < player2A.index.intValue?player1A:player2A;
        match2A = player1A.index.intValue > player2A.index.intValue?player1A:player2A;
        
        match1B = player1B.index.intValue < player2B.index.intValue?player1B:player2B;
        match2B = player1B.index.intValue > player2B.index.intValue?player1B:player2B;
        [self calc_OneOnOne:match1A matchB:match1B matchplay:isMatchplay operator:operator];
        [self calc_OneOnOne:match2A matchB:match2B matchplay:isMatchplay operator:operator];
    }else{
        //For cases where only two players in group
        match1A = player1A;
        match1B = player1B;
        [self calc_OneOnOne:match1A matchB:match1B matchplay:isMatchplay operator:operator];
    }
}

- (void) calc_OneOnOne:(PlayerInGroup *)matchA matchB:(PlayerInGroup *) matchB matchplay:(BOOL)isMatchplay operator:(NSPredicateOperatorType)operator{
    NSExpression *lhs, *rhs;
    NSPredicate *condition;

    Hole *match_holeA = [[matchA.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];
    Hole *match_holeB = [[matchB.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];

    lhs = [NSExpression expressionForConstantValue:match_holeA.result];
    rhs = [NSExpression expressionForConstantValue:match_holeB.result];
    condition = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier
                                                              type:operator options:0];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%@ == %@",match_holeA.result, match_holeB.result];
    
    if ([condition evaluateWithObject:@""]) { //team A winds
        match_holeA.teamScore = isMatchplay?[NSNumber numberWithInt:1]:match_holeA.result;
        match_holeB.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:match_holeB.result;
    }else if([predicate2 evaluateWithObject:@""]){ //halved
        match_holeA.teamScore = isMatchplay?[NSNumber numberWithInt:0]:match_holeA.result;
        match_holeB.teamScore = isMatchplay?[NSNumber numberWithInt:0]:match_holeB.result;
    }else { //teamB wins
        match_holeA.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:match_holeA.result;
        match_holeB.teamScore = isMatchplay?[NSNumber numberWithInt:1]:match_holeB.result;
    }

}

- (void) getTeam_result:(PlayerInGroup *)player1A player2A:(PlayerInGroup *) player2A player1B:(PlayerInGroup *) player1B player2B:(PlayerInGroup *) player2B
            matchplay:(BOOL)isMatchplay operator:(NSPredicateOperatorType)operator combined: (BOOL)isCombined{
    NSExpression *lhs, *rhs;
    NSPredicate *condition;
    NSNumber *teamscore1 = [NSNumber numberWithInt:0];
    NSNumber *teamscore2 = [NSNumber numberWithInt:0];
    
    Hole *holeOfPl1 = [[player1A.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];
    Hole *holeOfPl2 = [[player2A.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];
    Hole *holeOfPl3 = [[player1B.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];
    Hole *holeOfPl4 = [[player2B.hasScoreCard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects][0];
    
    
    if (isCombined) {
        teamscore1 = [NSNumber numberWithInt:holeOfPl1.result.intValue + holeOfPl2.result.intValue];
        teamscore2 = [NSNumber numberWithInt:holeOfPl3.result.intValue + holeOfPl4.result.intValue];
    }else{
        lhs = [NSExpression expressionForConstantValue:holeOfPl1.result];
        rhs = [NSExpression expressionForConstantValue:holeOfPl2.result];
        condition = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier
                                                                               type:operator options:0];//NSGreaterThanOrEqualToPredicateOperatorType
        if ([condition evaluateWithObject:@""]) { //holeOfPl1.result > holeOfPl2.result
            teamscore1 = holeOfPl1.result;
        }else{
            teamscore1 = holeOfPl2.result;
        }

        lhs = [NSExpression expressionForConstantValue:holeOfPl3.result];
        rhs = [NSExpression expressionForConstantValue:holeOfPl4.result];
        condition = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier
                                                                  type:operator options:0];//NSGreaterThanOrEqualToPredicateOperatorType
        if ([condition evaluateWithObject:@""]) {
            teamscore2 = holeOfPl3.result;
        }else{
            teamscore2 = holeOfPl4.result;
        }
    }
    
    
    
//    if (isCombined) {
//        teamscore2 = [NSNumber numberWithInt:holeOfPl3.result.intValue + holeOfPl4.result.intValue];
//    }else{
//        lhs = [NSExpression expressionForConstantValue:holeOfPl3.result];
//        rhs = [NSExpression expressionForConstantValue:holeOfPl4.result];
//        condition = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier
//                                                                  type:operator options:0];//NSGreaterThanOrEqualToPredicateOperatorType
//        if ([condition evaluateWithObject:@""]) {
//            teamscore2 = holeOfPl3.result;
//        }else{
//            teamscore2 = holeOfPl4.result;
//        }
//    }
    
    lhs = [NSExpression expressionForConstantValue:teamscore1];
    rhs = [NSExpression expressionForConstantValue:teamscore2];
    condition = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier
                                                              type:operator options:0];//NSGreaterThanOrEqualToPredicateOperatorType

    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%@ == %@",teamscore1, teamscore2];

    if ([condition evaluateWithObject:@""]) { //teamA wins
        holeOfPl1.teamScore = isMatchplay?[NSNumber numberWithInt:1]:teamscore1;
        holeOfPl2.teamScore = isMatchplay?[NSNumber numberWithInt:1]:teamscore1;
        holeOfPl3.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:teamscore2;
        holeOfPl4.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:teamscore2;
    }else if([predicate2 evaluateWithObject:@""]){ //halved
        holeOfPl1.teamScore = isMatchplay?[NSNumber numberWithInt:0]:teamscore1;
        holeOfPl2.teamScore = isMatchplay?[NSNumber numberWithInt:0]:teamscore1;
        holeOfPl3.teamScore = isMatchplay?[NSNumber numberWithInt:0]:teamscore2;
        holeOfPl4.teamScore = isMatchplay?[NSNumber numberWithInt:0]:teamscore2;
    }else { //teamB wins
        holeOfPl1.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:teamscore1;
        holeOfPl2.teamScore = isMatchplay?[NSNumber numberWithInt:-1]:teamscore1;
        holeOfPl3.teamScore = isMatchplay?[NSNumber numberWithInt:1]:teamscore2;
        holeOfPl4.teamScore = isMatchplay?[NSNumber numberWithInt:1]:teamscore2;
    }
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
    return [self.myGroup.hasPlayers count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return pictureSize+30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell" forIndexPath:indexPath];
    //clear cell
    for (UIView *sub in cell.subviews) {
        [sub removeFromSuperview];
    }

    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    PlayerInGroup *player = self.sortedPlayers[indexPath.row];
    Scorecard *scorecard = player.hasScoreCard;
    self.holesAR = [[scorecard.consistOf filteredSetUsingPredicate:self.predicateHoleNr] allObjects];
    Hole *hole = self.holesAR[0];
    if (indexPath.row == [self.myGroup.hasPlayers count]-1) {
        self.parLL.text = hole.par.stringValue;
        self.strokeLL.text = hole.stroke.stringValue;
    }

    PlayerUIView *playerView = [UIObjects getPlayerObj:0 y_coord:5 size:1.0 player:(PlayerInTourney *)player];
    [cell addSubview:playerView];
    
    //Input slider
    ScoringUISlider *score = [[ScoringUISlider alloc] initWithFrame:CGRectMake(61 ,0,self.view.frame.size.width - 62 - 80,pictureSize+30)];
    [score addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [score setBackgroundColor:[UIColor clearColor]];
    score.minimumValue = 1;
    score.maximumValue = 10;
    score.value = hole.score.floatValue;
    score.continuous = YES;
    score.tag = indexPath.row;
    score.holeMO = hole;
    score.playerMO = player;
    
    [cell addSubview:score];
    //    Score
    UILabel *scoreVal = [[UILabel alloc] initWithFrame:CGRectMake(61 + score.frame.size.width, 0, 40, pictureSize+30)];
    scoreVal.text = hole.score.stringValue;
    scoreVal.textColor = [UIColor whiteColor];
    scoreVal.textAlignment = NSTextAlignmentCenter;
    scoreVal.font = [UIFont fontWithName:mainFont size:38];
    scoreVal.tag = 1;
    [cell addSubview:scoreVal];
    // Result
    UILabel *scoreResult = [[UILabel alloc] initWithFrame:CGRectMake(61 + score.frame.size.width + scoreVal.frame.size.width, 0, 33, pictureSize+30)];
    scoreResult.text = hole.result.stringValue;
    scoreResult.textColor = [UIColor lightGrayColor];
    scoreResult.font = [UIFont fontWithName:mainFont size:26];
    scoreResult.tag = 2;
    [cell addSubview:scoreResult];
    //semantics
    UILabel *sematics = [[UILabel alloc]initWithFrame:CGRectMake(61 + score.frame.size.width, pictureSize+3, 40, 20)];
    if (hole.score.intValue == 0) {
        sematics.text = @"-";
    }else{
        sematics.text = [self getSemanticalScore:hole.score.intValue par:hole.par.intValue];
    }
    sematics.textColor = [UIColor lightGrayColor];
    sematics.font = [UIFont fontWithName:@"Kohinoor Devanagari" size:10];
    sematics.textAlignment = NSTextAlignmentCenter;
    sematics.tag = 3;
    [cell addSubview:sematics];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Exits
 --------------------*/
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
//    if ([identifier isEqualToString:@"save"]){
//        [self savedata];
//        if (!self.successfullSave) {
//            //cancel segue
//            return NO;
//        }else{
//            return YES;
//        }
//    }else{
//        return YES;
//    }
//}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"navigateToSC"]) {
        ScorecardViewController *scorecard = (ScorecardViewController *)[segue destinationViewController];
      scorecard.roundMO = self.roundMO;
        scorecard.myGroup = self.myGroup;
    }
}

- (IBAction)unwindToScoring:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"save"]) {
    }
}

@end
