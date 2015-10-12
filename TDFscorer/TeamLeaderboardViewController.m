//
//  TeamLeaderboardViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/22.
//  Copyright (c) 2015 DJ. All rights reserved.
//
const float widhtOfTeamDet = 50;
const float y_fromtop = 80;
const float heightOfRoundDet = 120;
const float widthOfPlayerDet = 70;
const float playerSizeFact = 0.7;
const float heightOfPoints = 30.0;
const float heightOfMatch = 90;
const float heightOfRoundHeading = 30.0;
const float heightOfGroupHeading = 15.0;
const float heightOfGroup = 100;
const float xfromLeftTeamLogo = 52;

#import "TeamLeaderboardViewController.h"
#import "Round.h"
#import "Tournament.h"
#import "Group.h"
#import "Competition.h"
#import "Team.h"
#import "PlayerInGroup.h"
#import "UIObjects.h"
#import "Constants.h"
@interface TeamLeaderboardViewController ()

@end

@implementation TeamLeaderboardViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    
    float y_of_Round = 0;//y_fromtop + 80;
    float x_fromside = 20;
    float y_of_group = 0;
    float team1Total = 0;
    float team2Total = 0;
    NSString *teamA, *teamB;
    BOOL firstTime = YES;

    PlayerInGroup *player1A, *player2A, *player1B, *player2B;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSSortDescriptor *sortDescriptorGrp = [[NSSortDescriptor alloc] initWithKey:@"groupid" ascending:YES];
    NSArray *sortDescriptorsGrp = [NSArray arrayWithObject:sortDescriptorGrp];

    NSArray *sortedRounds = [self.tourneyMO.hasRounds sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;

    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, y_fromtop + 80, self.view.frame.size.width, 1)];
    line.layer.borderWidth = 0.5;
    line.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:line];
    
    

// calculate total height
    float totalHeight = line.frame.origin.y;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, line.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, totalHeight)];
//    scrollView.contentSize = contentView.frame.size;
    [scrollView addSubview:contentView];
    
    for (Round *round in sortedRounds) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"compType beginswith 'Betterball' OR compType beginswith 'Combined' OR compType beginswith 'One-on-One'"];
        NSArray *compAR = [[round.hasComp filteredSetUsingPredicate:predicate] allObjects];
        if ([compAR count] > 0) {
            Competition *comp = compAR[0];
            
            //        if ([comp.compType containsString:@"Betterball"] || [comp.compType containsString:@"Combined"]) {
            UIView *roundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, y_of_Round, self.view.frame.size.width, heightOfRoundHeading + heightOfGroup * [round.hasGroups count])];
            totalHeight += roundContainer.frame.size.height;
            [contentView addSubview:roundContainer];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
            line.layer.borderWidth = 0.5;
            line.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [roundContainer addSubview:line];

            UILabel *roundLab =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, heightOfRoundHeading)];
            roundLab.textColor = [UIColor whiteColor];
            roundLab.text = [NSString stringWithFormat:@"%@%@%@%@",@"Round ",round.number.stringValue,@" - ",comp.compType];
            roundLab.textAlignment = NSTextAlignmentCenter;
            roundLab.font = [UIFont fontWithName:mainFont size:15];
            [roundContainer addSubview:roundLab];
            
            NSArray *sortedGroups = [round.hasGroups sortedArrayUsingDescriptors:sortDescriptorsGrp];
            for (Group *group in sortedGroups) {
                UIView *groupContainer = [[UIView alloc] initWithFrame:CGRectMake(0, heightOfRoundHeading, self.view.frame.size.width, heightOfGroup)];
                [roundContainer addSubview:groupContainer];
                
                UILabel *groupLab =[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 25, y_of_group, 50, heightOfGroupHeading)];
                groupLab.textColor = [UIColor whiteColor];
                groupLab.text = [NSString stringWithFormat:@"%@%@", @"Group: ",group.groupid];
                groupLab.textAlignment = NSTextAlignmentCenter;
                groupLab.font = [UIFont fontWithName:mainFont size:12];
                [groupContainer addSubview:groupLab];
                
                //Get players
//                if (firstTime) {
                    player1A = [group.hasPlayers allObjects][0];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team == %@",player1A.team];
                    NSArray *otherPl = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects];
                player1A = [otherPl count] > 0?otherPl[0]:nil;
                player2A = [otherPl count] == 2?otherPl[1]:nil;
                    teamA = player1A.team;
                    
                    predicate = [NSPredicate predicateWithFormat:@"team != %@",player1A.team];
                    otherPl = [[group.hasPlayers filteredSetUsingPredicate:predicate] allObjects];
                player1B = [otherPl count] > 0?otherPl[0]:nil;
                player2B = [otherPl count] == 2?otherPl[1]:nil;
                    teamB = player1B.team;
                    firstTime = NO;
//                }
                
                if ([comp.compType containsString:@"Betterball"] || [comp.compType containsString:@"Combined"]) {
                    //check
                    if (player1A == nil || player1B == nil || player2A == nil || player2B == nil) {
                        //raise error
                        [UIObjects showAlert:@"Configuration Error" message:@"Unequal Teams, please correct" tag:1];
                        return;
                    }
                    UILabel *versus =[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 20, y_of_group + 15, 40, 40)];
                    versus.textColor = [UIColor whiteColor];
                    versus.text = @"Vs";
                    versus.textAlignment = NSTextAlignmentCenter;
                    versus.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:versus];
                    //draw points
                    UILabel *team1Points =[[UILabel alloc] initWithFrame:CGRectMake(xfromLeftTeamLogo, y_of_group + heightOfGroup - heightOfPoints, widhtOfTeamDet, heightOfPoints)];
                    team1Points.textColor = [UIColor whiteColor];
                    team1Points.text = player1A.teamPoints == nil?@"-":player1A.teamPoints.stringValue;
                    team1Points.textAlignment = NSTextAlignmentCenter;
                    team1Points.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team1Points];
                    
                    UILabel *team2Points =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - xfromLeftTeamLogo - widhtOfTeamDet, y_of_group + heightOfGroup - heightOfPoints, widhtOfTeamDet, heightOfPoints)];
                    team2Points.textColor = [UIColor whiteColor];
                    team2Points.text = player1B.teamPoints == nil?@"-":player1B.teamPoints.stringValue;
                    team2Points.textAlignment = NSTextAlignmentCenter;
                    team2Points.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team2Points];
                    
                    team1Total += [self getteamTotals:player1A player_2:player1B status:round.status compType:comp.compType teamPoints:team1Points];
                    team2Total += [self getteamTotals:player1B player_2:player1A status:round.status compType:comp.compType teamPoints:team2Points];
                    
                }else{
                    //One-on-One
                    UILabel *versus =[[UILabel alloc] initWithFrame:CGRectMake(xfromLeftTeamLogo + (widhtOfTeamDet/2) - 20, y_of_group + 10, 40, 40)];
                    versus.textColor = [UIColor whiteColor];
                    versus.text = @"Vs";
                    versus.textAlignment = NSTextAlignmentCenter;
                    versus.font = [UIFont fontWithName:mainFont size:10];
                    [groupContainer addSubview:versus];
                    
                    UILabel *versus2 =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - xfromLeftTeamLogo - (widhtOfTeamDet/2) - 20, y_of_group + 10, 40, 40)];
                    versus2.textColor = [UIColor whiteColor];
                    versus2.text = @"Vs";
                    versus2.textAlignment = NSTextAlignmentCenter;
                    versus2.font = [UIFont fontWithName:mainFont size:10];
                    [groupContainer addSubview:versus2];
                    
                    PlayerInGroup *match1A, *match1B, *match2A, *match2B;
                    
                    if (player2A != nil && player2B != nil) {
                        match1A = player1A.index.intValue < player2A.index.intValue?player1A:player2A;
                        match2A = player1A.index.intValue > player2A.index.intValue?player1A:player2A;
                        
                        match1B = player1B.index.intValue < player2B.index.intValue?player1B:player2B;
                        match2B = player1B.index.intValue > player2B.index.intValue?player1B:player2B;
                        player1A = match1A;
                        player1B = match2A;
                        player2A = match1B;
                        player2B = match2B;
                    }else{
                        //For cases where only two players in group
                        player2A = player1B;
                        player1B = nil;
                    }
                    
                    //draw points
                    UILabel *team1APoints =[[UILabel alloc] initWithFrame:CGRectMake(x_fromside, y_of_group + heightOfGroup - heightOfPoints, 48, heightOfPoints)];
                    team1APoints.textColor = [UIColor whiteColor];
                    team1APoints.text = player1A.teamPoints == nil?@"-":player1A.teamPoints.stringValue;
                    team1APoints.textAlignment = NSTextAlignmentCenter;
                    team1APoints.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team1APoints];

                    UILabel *team2APoints =[[UILabel alloc] initWithFrame:CGRectMake(x_fromside + widthOfPlayerDet, y_of_group + heightOfGroup - heightOfPoints, 48, heightOfPoints)];
                    team2APoints.textColor = [UIColor whiteColor];
                    team2APoints.text = player2A.teamPoints == nil?@"-":player2A.teamPoints.stringValue;
                    team2APoints.textAlignment = NSTextAlignmentCenter;
                    team2APoints.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team2APoints];

                    [self getteamTotals:player1A player_2:player2A status:round.status compType:comp.compType teamPoints:team1APoints];
                    [self getteamTotals:player2A player_2:player1A status:round.status compType:comp.compType teamPoints:team2APoints];

                    UILabel *team1BPoints =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - x_fromside - 48, y_of_group + heightOfGroup - heightOfPoints, 48, heightOfPoints)];
                    team1BPoints.textColor = [UIColor whiteColor];
                    team1BPoints.text = player1B.teamPoints == nil?@"-":player1B.teamPoints.stringValue;
                    team1BPoints.textAlignment = NSTextAlignmentCenter;
                    team1BPoints.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team1BPoints];
                    
                    UILabel *team2BPoints =[[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - x_fromside - 50 - widthOfPlayerDet), y_of_group + heightOfGroup - heightOfPoints, 48, heightOfPoints)];
                    team2BPoints.textColor = [UIColor whiteColor];
                    team2BPoints.text = player2B.teamPoints == nil?@"-":player2B.teamPoints.stringValue;
                    team2BPoints.textAlignment = NSTextAlignmentCenter;
                    team2BPoints.font = [UIFont fontWithName:mainFont size:20];
                    [groupContainer addSubview:team2BPoints];

                    team1Total += [self getteamTotals:player1B player_2:player2B status:round.status compType:comp.compType teamPoints:team1BPoints];
                    team2Total += [self getteamTotals:player2B player_2:player1B status:round.status compType:comp.compType teamPoints:team2BPoints];
                }
                //Team 1 players (left)
                PlayerUIView *playerUI = [UIObjects getPlayerObj:x_fromside y_coord:y_of_group + heightOfGroupHeading size:playerSizeFact player:(PlayerInTourney *)player1A];
                [groupContainer addSubview:playerUI];
                playerUI = [UIObjects getPlayerObj:(x_fromside + widthOfPlayerDet) y_coord:y_of_group + heightOfGroupHeading size:playerSizeFact player:(PlayerInTourney *)player2A];
                [groupContainer addSubview:playerUI];
                
                //Team 2 players (right)
                playerUI = [UIObjects getPlayerObj:self.view.frame.size.width - x_fromside - 42 y_coord:y_of_group + heightOfGroupHeading size:playerSizeFact player:(PlayerInTourney *)player1B];
                [groupContainer addSubview:playerUI];
                playerUI = [UIObjects getPlayerObj:(self.view.frame.size.width - x_fromside - 42 - widthOfPlayerDet) y_coord:y_of_group + heightOfGroupHeading size:playerSizeFact player:(PlayerInTourney *)player2B];
                [groupContainer addSubview:playerUI];
                
                y_of_group = y_of_group + heightOfGroup;
            }
            //        } //if
            y_of_Round = y_of_Round + y_of_group + heightOfRoundHeading;//heightOfRoundDet;
            y_of_group = 0;
        }

    }
    
    contentView.frame = CGRectMake(0, 0, scrollView.frame.size.width, totalHeight);
    scrollView.contentSize = contentView.frame.size;

    //Teams
    NSArray *teams = [self.tourneyMO.hasTeams allObjects];
    if ([teams count] > 0) {
        Team *team1 = [((Team *)teams[0]).teamName isEqualToString:teamA]?(Team *)teams[0]:(Team *)teams[1];
        //Team Logo
        UIImageView *teamLogo =[[UIImageView alloc] initWithFrame:CGRectMake(x_fromside + 35,y_fromtop,widhtOfTeamDet,50)];
        teamLogo.image=[UIImage imageWithData:team1.teamImage];
        teamLogo.layer.cornerRadius = 2.0;
        teamLogo.clipsToBounds = YES;
        teamLogo.layer.borderWidth = 2.0;
        teamLogo.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
        [self.view addSubview:teamLogo];
        //Team Name
        UILabel *team1Lab =[[UILabel alloc] initWithFrame:CGRectMake(xfromLeftTeamLogo-20, y_fromtop + 50 + 5, widhtOfTeamDet+40, 25)];
        team1Lab.textColor = [UIColor whiteColor];
        team1Lab.text = team1.teamName;
        team1Lab.textAlignment = NSTextAlignmentCenter;
        team1Lab.font = [UIFont fontWithName:mainFont size:15];
        [self.view addSubview:team1Lab];
        //Team total
        UILabel *team1Tot =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 55, y_fromtop + 12, 50, 30)];
        team1Tot.textColor = [UIColor whiteColor];
        team1Tot.text = [NSNumber numberWithFloat:team1Total].stringValue;
        team1Tot.textAlignment = NSTextAlignmentCenter;
        team1Tot.font = [UIFont fontWithName:mainFont size:35];
//        team1Tot.layer.borderWidth = 2.0;
//        team1Tot.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:team1Tot];

        Team *team2 = [((Team *)teams[1]).teamName isEqualToString:teamB]?(Team *)teams[1]:(Team *)teams[0];
        //Team Logo
        UIImageView *teamLogo2 =[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - x_fromside -35 - widhtOfTeamDet,y_fromtop,widhtOfTeamDet,50)];
        teamLogo2.image=[UIImage imageWithData:team2.teamImage];
        teamLogo2.layer.cornerRadius = 2.0;
        teamLogo2.clipsToBounds = YES;
        teamLogo2.layer.borderWidth = 2.0;
        teamLogo2.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
        [self.view addSubview:teamLogo2];
        //Team Name
        UILabel *team2Lab =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - xfromLeftTeamLogo - widhtOfTeamDet - 25, y_fromtop + 50 + 5, widhtOfTeamDet+40, 25)];
        team2Lab.textColor = [UIColor whiteColor];
        team2Lab.text = team2.teamName;
        team2Lab.textAlignment = NSTextAlignmentCenter;
        team2Lab.font = [UIFont fontWithName:mainFont size:15];
        [self.view addSubview:team2Lab];
        //Team total
        UILabel *team2Tot =[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 5, y_fromtop + 12, 50, 30)];
        team2Tot.textColor = [UIColor whiteColor];
        team2Tot.text = [NSNumber numberWithFloat:team2Total].stringValue;
        team2Tot.textAlignment = NSTextAlignmentCenter;
        team2Tot.font = [UIFont fontWithName:mainFont size:35];
//        team2Tot.layer.borderWidth = 2.0;
//        team2Tot.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:team2Tot];

    }
}

- (void) viewDidAppear:(BOOL)animated{
    
    
}
/*-------------------
 Actions
 --------------------*/

/*-------------------
 Save & Load
 --------------------*/

/*-------------------
 Helpers
 --------------------*/
- (float) getteamTotals:(PlayerInGroup*)player_1 player_2:(PlayerInGroup*)player_2 status:(NSString *)status compType:(NSString *)compType teamPoints:(UILabel *)teamPoints{
    float teamTotal = 0;
    if (player_1.teamPoints.floatValue == player_2.teamPoints.floatValue) {
        teamTotal = [status isEqualToString:@"completed"]?0.5:0;
        teamPoints.textColor = [UIColor whiteColor];
    }else{
        if ([compType containsString:@"Matchplay"]) {
            if (player_1.teamPoints.floatValue > player_2.teamPoints.floatValue) {
                teamTotal = [status isEqualToString:@"completed"]?1:0;
                teamPoints.textColor = [UIColor greenColor];
            }else{
                teamPoints.textColor = [UIColor redColor];
            }
        }else if ([compType containsString:@"Stableford"]){
            if (player_1.teamPoints.floatValue > player_2.teamPoints.floatValue) {
                teamTotal = [status isEqualToString:@"completed"]?1:0;
                teamPoints.textColor = [UIColor greenColor];
            }else{
                teamPoints.textColor = [UIColor redColor];
            }
        }else{ //Strokeplay
            if (player_1.teamPoints.floatValue < player_2.teamPoints.floatValue) {
                teamTotal = [status isEqualToString:@"completed"]?1:0;
                teamPoints.textColor = [UIColor greenColor];
            }else{
                teamPoints.textColor = [UIColor redColor];
            }
        }
    }
    return teamTotal;
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

@end
