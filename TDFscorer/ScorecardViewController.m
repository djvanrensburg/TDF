//
//  ScorecardViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/12.
//  Copyright (c) 2015 DJ. All rights reserved.
//
const float h_of_row = 32;

#import "Group.h"
#import "Course.h"
#import "PlayerInGroup.h"
#import "Scorecard.h"
#import "Hole.h"
#import "Competition.h"
#import "Round.h"
#import "Constants.h"

#import "ScorecardViewController.h"

@interface ScorecardViewController ()
@property NSMutableArray *playersToShow;
@property NSMutableArray *holesAR;
@property UITableView *headingsTV;
@property UITableView *players1TV;
@property UITableView *teams1TV;
@property UITableView *players2TV;
@property UITableView *teams2TV;
@property BOOL showAll;
@property BOOL isOnonOne;
@property BOOL firstTime;
@end

@implementation ScorecardViewController

/*-------------------
 Initiators
 --------------------*/
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
-(void) viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad {
    self.firstTime = YES;
    float tableheight;
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    //    NSString *title = [NSString stringWithFormat:@"%@%@%@",self.roundMO.isOfCourse.courseName, @" - ",]
    self.title = self.roundMO.isOfCourse.courseName;
    
    NSMutableArray *playersAR = [[NSMutableArray alloc] init];
    
    for (Group *group in self.roundMO.hasGroups){
        [playersAR addObjectsFromArray:[group.hasPlayers allObjects]];
    }
    
    PlayerInGroup *player = playersAR[0];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holeNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.holesAR = [player.hasScoreCard.consistOf allObjects].mutableCopy;
    self.holesAR = [self.holesAR sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;

    if (self.showAll) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalPoints" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.playersToShow = [playersAR sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    }else{
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.playersToShow = [self.myGroup.hasPlayers sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
        
        self.isOnonOne = NO;
        for (Competition *comp in self.roundMO.hasComp) {
            if ([comp.compType containsString:@"One-on-One"]) {
                self.isOnonOne = YES;
                break;
            }
        }
        if (!self.isOnonOne) {
            self.teams2TV.hidden = YES;
            self.players2TV.hidden = YES;
        }
    }

    //headings
    self.headingsTV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100 ) style:UITableViewStylePlain];
    self.headingsTV.clipsToBounds = YES;
    self.headingsTV.tag = 0;
    self.headingsTV.backgroundColor = [UIColor clearColor];
    self.headingsTV.delegate = self;
    self.headingsTV.dataSource = self;
    [self.headingsTV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"headingCell"];
    self.headingsTV.scrollEnabled = NO;
    [self.view addSubview:self.headingsTV];

    float totalHeight = 100.0 + self.navigationController.toolbar.frame.size.height;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:scrollView];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, totalHeight)];
    //    scrollView.contentSize = contentView.frame.size;
    [scrollView addSubview:contentView];
    
    //PLayers
    if (self.isOnonOne && !self.showAll && [self.playersToShow count] > 2) {
        tableheight = h_of_row * [self.playersToShow count] / 2;
    }else{
        tableheight = h_of_row * [self.playersToShow count];
    }
//    if (tableheight > self.view.frame.size.height-self.headingsTV.frame.size.height-self.navigationController.toolbar.frame.size.height) {
//        tableheight = self.view.frame.size.height-self.headingsTV.frame.size.height-self.navigationController.toolbar.frame.size.height;
//    }
    self.players1TV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableheight ) style:UITableViewStylePlain];
    self.players1TV.clipsToBounds = YES;
    self.players1TV.tag = 1;
    self.players1TV.backgroundColor = [UIColor blackColor];
    self.players1TV.layer.cornerRadius = 8.0;
//    self.players1TV.layer.borderWidth = 1.0;
    self.players1TV.delegate = self;
    self.players1TV.dataSource = self;
    [self.players1TV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"playerCell1"];
    self.players1TV.scrollEnabled = NO;
    [contentView addSubview:self.players1TV];
    totalHeight +=self.players1TV.frame.size.height;
    //Teams
    if (!self.showAll) {
        self.teams1TV = [[UITableView alloc]initWithFrame:CGRectMake(0, tableheight + 15, self.view.frame.size.width, h_of_row * 2 ) style:UITableViewStylePlain];
        self.teams1TV.clipsToBounds = YES;
        self.teams1TV.tag = 2;
        self.teams1TV.backgroundColor = [UIColor clearColor];
        self.teams1TV.delegate = self;
        self.teams1TV.dataSource = self;
        [self.teams1TV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"teamCell1"];
        self.teams1TV.scrollEnabled = NO;
        [contentView addSubview:self.teams1TV];
        totalHeight +=self.teams1TV.frame.size.height;
    }

    //PLayers2
    if (self.isOnonOne && !self.showAll && [self.playersToShow count] > 2) {
        tableheight = h_of_row * [self.playersToShow count] / 2;
        self.players2TV = [[UITableView alloc]initWithFrame:CGRectMake(0, tableheight + 10 + h_of_row * 2, self.view.frame.size.width, tableheight ) style:UITableViewStylePlain];
        self.players2TV.clipsToBounds = YES;
        self.players2TV.tag = 3;
        self.players2TV.backgroundColor = [UIColor blackColor];
        self.players2TV.layer.cornerRadius = 8.0;
        self.players2TV.delegate = self;
        self.players2TV.dataSource = self;
        [self.players2TV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"playerCell2"];
        self.players2TV.scrollEnabled = NO;
        [contentView addSubview:self.players2TV];
        totalHeight +=self.players2TV.frame.size.height;
        //Teams2
        self.teams2TV = [[UITableView alloc]initWithFrame:CGRectMake(0, tableheight + 20 + h_of_row *2 + tableheight, self.view.frame.size.width, h_of_row * 2 ) style:UITableViewStylePlain];
        self.teams2TV.clipsToBounds = YES;
        self.teams2TV.tag = 4;
        self.teams2TV.backgroundColor = [UIColor clearColor];
        self.teams2TV.delegate = self;
        self.teams2TV.dataSource = self;
        [self.teams2TV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"teamCell2"];
        self.teams2TV.scrollEnabled = NO;
        [contentView addSubview:self.teams2TV];
        totalHeight +=self.teams2TV.frame.size.height;
    }else{
        self.teams2TV.hidden = YES;
        self.players2TV.hidden = YES;
    }

    contentView.frame = CGRectMake(0, 0, scrollView.frame.size.width, totalHeight);
    scrollView.contentSize = contentView.frame.size;
    scrollView.scrollEnabled = YES;
//    [self.headingsTV reloadData];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
//    return YES;
//}

/*-------------------
 Actions
 --------------------*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self performSegueWithIdentifier:@"navBack" sender:self];
}

- (IBAction)showAllPlayers:(id)sender {
    self.showAll = YES;
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    [self viewDidLoad];
}
- (IBAction)showGroup:(id)sender {
    self.showAll = NO;
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    [self viewDidLoad];
}

/*-------------------
 Save & Load
 --------------------*/

/*-------------------
 Helpers
 --------------------*/
- (void) drawPlayerRow:(PlayerInGroup *)player cell:(UITableViewCell *)cell x_hole:(float) x_hole w_hole:(float) w_of_hole{
    UIColor *textcol = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0];

    UILabel *playerName =[[UILabel alloc] initWithFrame:CGRectMake(3, 0, x_hole-5, h_of_row)];
    playerName.textColor = [UIColor whiteColor];
    playerName.text = player.friendName;
    playerName.textAlignment = NSTextAlignmentLeft;
    playerName.font = [UIFont fontWithName:mainFont size:10];
    [cell addSubview:playerName];
    
    //handicap
    UILabel *handicap = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, x_hole-2,h_of_row)];
    handicap.textColor = [UIColor whiteColor];
    handicap.text = player.adjustedHC.stringValue;
    handicap.textAlignment = NSTextAlignmentLeft;
    handicap.font = [UIFont fontWithName:mainFont size:8];
    [cell addSubview:handicap];

    //team
    UILabel *team = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, x_hole-2,h_of_row)];
    team.textColor = [UIColor lightGrayColor];
    team.text = player.team;
    team.textAlignment = NSTextAlignmentLeft;
    team.font = [UIFont fontWithName:mainFont size:8];
    [cell addSubview:team];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holeNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *myHoles = [player.hasScoreCard.consistOf allObjects].mutableCopy;
    myHoles = [myHoles sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    
    NSNumber *totalScore = [NSNumber numberWithInt:0];
    NSNumber *front9 = [NSNumber numberWithInt:0];
    NSNumber *totalResult = [NSNumber numberWithInt:0];
    NSNumber *front9res = [NSNumber numberWithInt:0];
    //Rest of the Columns are the Holes
    for (Hole *hole in myHoles){
        if (hole.holeNumber.intValue == 10) {
            x_hole = x_hole + w_of_hole;
        }
        UILabel *par =[[UILabel alloc] initWithFrame:CGRectMake(x_hole-5, 0, w_of_hole, h_of_row * 0.66)];
        par.text = hole.score.stringValue;
        par.textAlignment = NSTextAlignmentCenter;
        totalScore = [NSNumber numberWithInt:totalScore.intValue + hole.score.intValue];
        par.font = [UIFont fontWithName:@"Noteworthy" size:14];
        par.textColor = [UIColor whiteColor];
        
        [cell addSubview:par];
        
        UILabel *stroke =[[UILabel alloc] initWithFrame:CGRectMake(x_hole+5, h_of_row * 0.66 - 3 , w_of_hole, h_of_row * 0.33)];
        stroke.text = hole.result.stringValue;
        stroke.textAlignment = NSTextAlignmentCenter;
        totalResult = [NSNumber numberWithInt:totalResult.intValue + hole.result.intValue];
        stroke.font = [UIFont fontWithName:@"Noteworthy" size:10];
        stroke.textColor = [UIColor lightGrayColor];
        
        [cell addSubview:stroke];
        x_hole = x_hole + w_of_hole;

        if (hole.holeNumber.intValue == 9 || hole.holeNumber.intValue == 18) {
            front9 = [self drawTotals:cell x_hole:x_hole y_hole:0 w_hole:w_of_hole+5 h_hole:h_of_row * 0.66 hole:hole totalScore:totalScore front9:front9 fontSize:14 textColor:textcol];
            front9res = [self drawTotals:cell x_hole:x_hole+5 y_hole:(h_of_row * 0.66 - 3) w_hole:w_of_hole h_hole:h_of_row * 0.33 hole:hole totalScore:totalResult front9:front9res fontSize:10 textColor:[UIColor whiteColor]];
        }
    }
    //add totals
}

- (void) drawTeamRow:(PlayerInGroup *)player cell:(UITableViewCell *)cell x_hole:(float) x_hole w_hole:(float) w_of_hole{
    UIColor *textcol = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0];
    
    UILabel *teamName =[[UILabel alloc] initWithFrame:CGRectMake(3, 0, x_hole, h_of_row-10)];
    teamName.textColor = [UIColor whiteColor];
    teamName.text = player.team;
    teamName.textAlignment = NSTextAlignmentLeft;
    teamName.font = [UIFont fontWithName:mainFont size:10];
    [cell addSubview:teamName];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holeNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *myHoles = [player.hasScoreCard.consistOf allObjects].mutableCopy;
    myHoles = [myHoles sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
    
    //Rest of the Columns are the Holes
    NSNumber *totalScore = [NSNumber numberWithInt:0];
    NSNumber *front9 = [NSNumber numberWithInt:0];
    for (Hole *hole in myHoles){
        if (hole.holeNumber.integerValue == 10) {
            x_hole = x_hole + w_of_hole;
        }
        UILabel *teamScore =[[UILabel alloc] initWithFrame:CGRectMake(x_hole, 0, w_of_hole * 0.66, h_of_row - 10)];
        teamScore.text = hole.teamScore.stringValue;
        totalScore = [NSNumber numberWithInt:totalScore.intValue + hole.teamScore.intValue];
        teamScore.font = [UIFont fontWithName:@"Noteworthy" size:15];
        teamScore.textColor = [UIColor whiteColor];
        
        [cell addSubview:teamScore];
        
        x_hole = x_hole + w_of_hole;
        if (hole.holeNumber.intValue == 9 || hole.holeNumber.intValue == 18) {
            front9 = [self drawTotals:cell x_hole:x_hole y_hole:0 w_hole:w_of_hole h_hole:h_of_row-10 hole:hole totalScore:totalScore front9:front9 fontSize:15 textColor:textcol];
        }
    }
}

- (NSNumber *) drawTotals:(UITableViewCell *)cell x_hole:(float) x_hole y_hole:(float) y_hole w_hole:(float) w_of_hole h_hole:(float) h_of_hole hole:(Hole *)hole totalScore:(NSNumber *)totalScore front9:(NSNumber *)front9 fontSize:(CGFloat)fsize textColor:(UIColor*)textCol{

    UIFont *textfont = [UIFont fontWithName:@"Noteworthy" size:fsize];
    
        UILabel *subTotal = [[UILabel alloc] initWithFrame:CGRectMake(x_hole, y_hole, w_of_hole * 0.66+5, h_of_hole)];
        if (hole.holeNumber.intValue == 9) {
            front9 = totalScore;
            subTotal.text = totalScore.stringValue;
        }else{
            subTotal.text = [NSNumber numberWithInt:totalScore.intValue - front9.intValue].stringValue;
            //Grand total
            UILabel *grandTotal = [[UILabel alloc] initWithFrame:CGRectMake(x_hole + w_of_hole - 5, y_hole, w_of_hole * 0.66+5, h_of_hole)];
            grandTotal.text = totalScore.stringValue;
            grandTotal.font = textfont;
            grandTotal.textColor = textCol;
            [cell addSubview:grandTotal];
        }
    subTotal.font = textfont;
        subTotal.textColor = textCol;
        [cell addSubview:subTotal];
    return front9;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int rows = 0;
    switch (tableView.tag) {
        case 0:
            //headings
            rows = 2;
            break;
        case 1:
            //Players
            if (self.isOnonOne && [self.playersToShow count] > 2) {
                rows = [self.playersToShow count] / 2;
            }else{
                rows = [self.playersToShow count];
            }
            break;
        case 2:
            //Teams
            return 2;
            break;
        case 3:
            //Players
            if (self.isOnonOne) {
                rows = [self.playersToShow count] / 2;
            }else{
                rows = 0;
            }
            break;
        case 4:
            //Teams
            return 2;
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = h_of_row;
    switch (tableView.tag) {
        case 2:
            height = height - 10;
            break;
        case 4:
            height = height - 10;
            break;
    }
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.firstTime = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    float width = self.view.frame.size.width;
    float x_hole = 100;
    float w_of_hole = (width - x_hole) / 21;
    BOOL dontDraw = NO;
    
    UITableViewCell *cell;
//    if (self.firstTime) {
    switch (tableView.tag) {
        case 0: {//Headings
            cell = [tableView dequeueReusableCellWithIdentifier:@"headingCell" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            if (indexPath.row == 0) {
                for (Hole *hole in self.holesAR){
                    if (hole.holeNumber.integerValue == 10) {
                        x_hole = x_hole + w_of_hole;
                    }
                    UILabel *holeNr =[[UILabel alloc] initWithFrame:CGRectMake(x_hole, 0, w_of_hole, h_of_row)];
                    holeNr.text = hole.holeNumber.stringValue;
                    holeNr.font = [UIFont fontWithName:mainFont size:20];
                    holeNr.textColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0];
                    holeNr.textAlignment = NSTextAlignmentCenter;
                    [cell addSubview:holeNr];
                    x_hole = x_hole + w_of_hole;
                }
            }else{
                UILabel *playerNameLab =[[UILabel alloc] initWithFrame:CGRectMake(3, 0, x_hole, h_of_row)];
                playerNameLab.textColor = [UIColor whiteColor];
                playerNameLab.text = @"Player";
                playerNameLab.textAlignment = NSTextAlignmentLeft;
                playerNameLab.font = [UIFont fontWithName:mainFont size:15];
                [cell addSubview:playerNameLab];
                
                UILabel *parLab =[[UILabel alloc] initWithFrame:CGRectMake(x_hole - 45, 0, 25, h_of_row/2)];
                parLab.textColor = [UIColor whiteColor];
                parLab.text = @"Par";
                parLab.font = [UIFont fontWithName:mainFont size:9];
                [cell addSubview:parLab];
                
                UILabel *strokeLab =[[UILabel alloc] initWithFrame:CGRectMake(x_hole - 45, h_of_row/2, 30, h_of_row/2)];
                strokeLab.textColor = [UIColor whiteColor];
                strokeLab.text = @"Stroke";
                strokeLab.font = [UIFont fontWithName:mainFont size:9];
                [cell addSubview:strokeLab];
                
                
                //Rest of the Columns are the Holes
                for (Hole *hole in self.holesAR){
                    if (hole.holeNumber.integerValue == 10) {
                        x_hole = x_hole + w_of_hole;
                    }
                    UILabel *par =[[UILabel alloc] initWithFrame:CGRectMake(x_hole-3, 0, w_of_hole, h_of_row * 0.66)];
                    par.text = hole.par.stringValue;
                    par.textAlignment = NSTextAlignmentCenter;
                    par.font = [UIFont fontWithName:mainFont size:16];
                    par.textColor = [UIColor whiteColor];
                    
                    [cell addSubview:par];
                    
//                    UILabel *stroke =[[UILabel alloc] initWithFrame:CGRectMake(x_hole + (w_of_hole * 0.66) - 12, h_of_row * 0.66 - 3 , w_of_hole * 0.5 + 3, h_of_row * 0.33)];
                    UILabel *stroke =[[UILabel alloc] initWithFrame:CGRectMake(x_hole+3, h_of_row * 0.66 - 3 , w_of_hole, h_of_row * 0.33)];
                    stroke.text = hole.stroke.stringValue;
                    stroke.textAlignment = NSTextAlignmentCenter;
                    stroke.font = [UIFont fontWithName:mainFont size:12];
                    stroke.textColor = [UIColor lightGrayColor];
                    
                    [cell addSubview:stroke];
                    x_hole = x_hole + w_of_hole;
                }
            }
            break;
        }case 1: {//Players
//            if (self.firstTime) {
//                self.firstTime = NO;
                cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell1" forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                PlayerInGroup *player = self.playersToShow[indexPath.row];
                [self drawPlayerRow:player cell:cell x_hole:x_hole w_hole:w_of_hole];
                break;
//            }
        }case 2: {//Teams
            cell = [tableView dequeueReusableCellWithIdentifier:@"teamCell1" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            PlayerInGroup *player;
            if (self.isOnonOne) {
                player = self.playersToShow[indexPath.row];
            }else{
                player = self.playersToShow[0];
                if (indexPath.row == 1) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team != %@",player.team];
                    NSArray *playersOfTeam = [self.playersToShow filteredArrayUsingPredicate:predicate];
                    if ([playersOfTeam count] > 0) {
                        player = playersOfTeam[0];
                    }
                }
            }
            
            [self drawTeamRow:player cell:cell x_hole:x_hole w_hole:w_of_hole];
            break;
        }case 3: {//Players
            cell = [tableView dequeueReusableCellWithIdentifier:@"playerCell2" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            @try {
                PlayerInGroup *player = self.playersToShow[indexPath.row+2];
                [self drawPlayerRow:player cell:cell x_hole:x_hole w_hole:w_of_hole];
            }
            @catch (NSException *exception) {
                
            }
            break;
        }case 4: {//Teams
            cell = [tableView dequeueReusableCellWithIdentifier:@"teamCell2" forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

            PlayerInGroup *player;
            if (self.isOnonOne) {
                @try {
                    player = self.playersToShow[indexPath.row + 2];
                }
                @catch (NSException *exception) {
                    //don't draw
                    dontDraw = YES;
                }
            }else{
                player = self.playersToShow[0];
                if (indexPath.row == 1) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"team != %@",player.team];
                    player = [self.playersToShow filteredArrayUsingPredicate:predicate][0];
                }
            }
            if (!dontDraw) {
                [self drawTeamRow:player cell:cell x_hole:x_hole w_hole:w_of_hole];
            }
            break;
        }
    }
//    }

    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
/*-------------------
 PickerViews
 --------------------*/

/*-------------------
 Exits
 --------------------*/

@end
