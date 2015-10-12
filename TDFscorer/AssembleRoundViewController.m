//
//  AssembleRoundViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/14.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "PlayerInGroup.h"
#import "Scorecard.h"
#import "GroupUIView.h"
#import "PlayerUIView.h"
#import "Group.h"
#import <CoreData/CoreData.h>
#import "Hole.h"
#import "Competition.h"
#import "Constants.h"
#import "ScrollContentView.h"
#import "GDriveUtils.h"
#import "UIObjects.h"
const float spaceBetweenGroups = 130;
const float spaceBetweenAvailPl = 100;
const float spaceBetweenSideAndGroup = 80;

@interface AssembleRoundViewController ()

@property (weak, nonatomic) IBOutlet UILabel *testlabel;
//@property PlayerUIView *draggedView;
//@property UIView *swappedView;
@property (weak, nonatomic) IBOutlet UIScrollView *availablePlayersSV;
//@property (weak, nonatomic) IBOutlet UIScrollView *groupsSV;
@property NSMutableArray *playerViewsAR;
@property NSMutableArray *groupsViewsAR;
//@property CGRect selectedFrame;
//@property CGPoint selectedPoint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBT;
//@property CGRect availableFrame;
@property int countGroups;
@property CGFloat y_Group;
@property float colSize;
@property UIScrollView *scroll;
@property ScrollContentView *content;
//@property NSSet *placesPosNS;
@end

@implementation AssembleRoundViewController


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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colSize = self.view.frame.size.width / 5;
    self.title = [NSString stringWithFormat:@"%@%@", @"Assemble Round ", self.roundMO.number.stringValue];
    
//    UILabel *tmp = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 80, self.view.frame.size.height-65)];
//    self.availableFrame = tmp.frame;
    
    self.availablePlayersSV.layer.borderWidth = 2.0;
    self.availablePlayersSV.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.playerViewsAR = [[NSMutableArray alloc] init];
    self.groupsViewsAR = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    
    self.countGroups = [self.tourneyMO.hasPlayers count] / 4;
    if ([self.tourneyMO.hasPlayers count] % 4 > 0) {
        self.countGroups++;
    }
    [self setup4Balls:self.countGroups];
    
    //draw all available player
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.colSize, self.view.frame.size.height)];
    self.scroll.tag = 1;
    [self.view addSubview:self.scroll];
     self.content = [[ScrollContentView alloc] initWithFrame:CGRectMake(0, 0, self.scroll.frame.size.width, 70 + (80 + spaceBetweenAvailPl) * [self.tourneyMO.hasPlayers count]) assembler:self];
    self.scroll.contentSize = self.content.frame.size;
//    content.draggedView = self.draggedView;
    self.content.tag = 2;
    [self.scroll addSubview:self.content];
    CGFloat x = 0;//(self.colSize - playerWidth)/2;
    CGFloat y = 70;
    for (int i = 0; i < [self.tourneyMO.hasPlayers count]; i ++) {
        PlayerInTourney *player = [self.tourneyMO.hasPlayers allObjects][i];
        PlayerUIView *playerView = [UIObjects getPlayerObj:x y_coord:y size:1.0 player:player ];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
//        [playerView addGestureRecognizer:singleTap];
        
        [self.content addSubview:playerView];
        [self.playerViewsAR addObject:playerView];
        
        y = y + spaceBetweenAvailPl;
    }
    //Draw separator
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.colSize, 0, 1, self.view.frame.size.height)];
    separator.layer.borderColor = [UIColor whiteColor].CGColor;
    separator.layer.borderWidth = 1;
    
    [self.view addSubview:separator];
}

- (void) setup4Balls:(int)count {
    
    self.y_Group = 65;
    
    for (int i = 0; i < count; i++) {
        [self addGrouping:i xVal:spaceBetweenSideAndGroup yVal:self.y_Group];
        self.y_Group = self.y_Group + spaceBetweenGroups;
    }
    //    return count;
}
/*-------------------
 Actions
 --------------------*/
//- (IBAction)saveAction:(id)sender {
//    [self save];
//}
- (IBAction)setGroups:(id)sender {
    if ([self.playerViewsAR count] == 0){
        [self save];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Incomplete Groups"
                                                        message: @"Please place all the players in a group"
                                                       delegate: nil
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }

//    [self save];
}

- (IBAction)addGroup:(id)sender {
    [self addGrouping:self.countGroups xVal:spaceBetweenSideAndGroup yVal:self.y_Group];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture{
    
//    self.draggedView = nil;
//    // Determine which player was touched
//    if ([gesture.view isKindOfClass:[PlayerUIView class]]) {
//        self.draggedView = (PlayerUIView *)gesture.view;
//        self.selectedFrame = self.draggedView.frame;
//        self.selectedPoint = self.draggedView.center;
//    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches ] anyObject];
    self.draggedView = nil;
    // Determine which player was touched
//    for (UIView *scroll in self.view.subviews) {
//        if (scroll.tag == 1) {
//            for (UIView *content in scroll.subviews) {
//                if (content.tag == 2) {
                    for (UIView *playerView in self.view.subviews) {
                        if (touch.view == playerView && [touch.view isKindOfClass:[PlayerUIView class]]) {
                            self.draggedView = (PlayerUIView *)playerView;
                            self.selectedFrame = self.draggedView.frame;
                            self.selectedPoint = self.draggedView.center;
                            break;
                        }
                    }
//                }
//            }
//        }
//    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches ] anyObject];
    CGPoint location = [touch locationInView:self.view];
    self.draggedView.center = CGPointMake(location.x, location.y);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];

    if (self.draggedView != nil) {
        BOOL dropZoneFound = NO;
        int numOfGroups = 0;
        int numOfPlayersInGrp = 0;
        UILabel *counter;
        for (GroupUIView *group in self.groupsViewsAR) {
            if (CGRectContainsPoint(group.frame, self.draggedView.center) && numOfPlayersInGrp < 4 && !CGRectContainsPoint(group.frame, self.selectedPoint)) {
                //Dropped in Group
                counter = group.subviews[1];
                numOfPlayersInGrp = [counter.text intValue];
                if (numOfPlayersInGrp == 4){
                    break;
                }
                //check if self.draggedView.center colides with existing player...
                PlayerInGroup * groupP = [self setPlacement:numOfPlayersInGrp numOfGrps:numOfGroups];

                numOfPlayersInGrp = numOfPlayersInGrp + 1;
                counter.text = [NSNumber numberWithInt:numOfPlayersInGrp].stringValue;
                
                [group.groupMO addHasPlayersObject:groupP];

                //remove from available container
                [self.playerViewsAR removeObject:self.draggedView];
                dropZoneFound = YES;
            }else{
                for (PlayerInGroup *player in group.groupMO.hasPlayers) {
                    if ([self.draggedView.player.email isEqualToString:player.email]) {
                        //dragged player is originates from this group
                        counter = group.subviews[1];
                        numOfPlayersInGrp = [counter.text intValue];
                        break;
                    }
                }
            }
            numOfGroups = numOfGroups + 1;
        }
        if (dropZoneFound == NO) {
            if(CGRectContainsPoint(self.scroll.frame, self.draggedView.center)){
                // in available container
                if (![self.playerViewsAR containsObject:self.draggedView]) {
                    [self.playerViewsAR addObject:self.draggedView];
                }
                numOfPlayersInGrp = numOfPlayersInGrp - 1;
                counter.text = [NSNumber numberWithInt:numOfPlayersInGrp].stringValue;
                //remove from GroupView
                for (GroupUIView *group in self.groupsViewsAR) {
                    for (PlayerInGroup *player in group.groupMO.hasPlayers) {
                        if ([self.draggedView.player.email isEqualToString:player.email]) {
                            [group.groupMO removeHasPlayersObject:player];
                            self.draggedView.playerNum = -1;
                            self.draggedView.groupNum = -1;
                            [self.theTournamentContext deleteObject:player];
                            break;
                        }
                    }
                }
            }else{
                self.draggedView.frame = self.selectedFrame;
            }
        }
        self.draggedView = nil;
        //rearrange available players
        CGFloat y = 70;
        for (int i=0; i < [self.playerViewsAR count]; i++) {
            UIView *playView = self.playerViewsAR[i];
            [playView removeFromSuperview];
            [playView setFrame:CGRectMake(0, y, playView.frame.size.width, playView.frame.size.height)];
            for (UIView *subv in playView.subviews) {
                if (subv.tag == 1) {
                    subv.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
                    break;
                }
            }
            
            [self.content addSubview:playView];
             y = y + spaceBetweenAvailPl;
        }
    }
}
/*-------------------
 Save & Load
 --------------------*/
- (void) save{
    //first clear any previous assemblies
    [self.roundMO removeHasGroups:[self.roundMO hasGroups]];
    for (GroupUIView *group in self.groupsViewsAR) {
        [self.roundMO addHasGroupsObject:group.groupMO];
        
        for (PlayerInGroup *player in group.groupMO.hasPlayers) {
            //Managed Object for Scorecard
            player.hasScoreCard = [self populateScorecard];
        }
    }
    self.roundMO.status = @"assembled";
    
//    [[self managedObjectContext] insertObject:self.roundMO];
    
    if (self.tourneyMO.internetPlay.boolValue) {
        //update Gdrive
        GDriveUtils *gDriveUtil = [[GDriveUtils alloc] init:self];
        NSDictionary *tournamentNS = [self.tourneyMO toDictionary :YES];
        if ([gDriveUtil isAuthorized]){
            [gDriveUtil saveToGDrive:self.tourneyMO.id_of_Tournament tourInst:tournamentNS fileID:self.tourneyMO.gDriveFileID players:nil suppressAlert:YES doShare:NO tourName:self.tourneyMO.tournamentName];
        }else{
            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
            [self.navigationController pushViewController:[gDriveUtil createAuthController] animated:YES];
        }
    }else{
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.theTournamentContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self performSegueWithIdentifier:@"save" sender:self];
    }
}
/*-------------------
 Helpers
 --------------------*/
-(void)notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    if (crud != nil) {
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.theTournamentContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self performSegueWithIdentifier:@"save" sender:self];
    }
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
- (PlayerInGroup *) setPlacement:(int)numOfPlrs numOfGrps:(int)numOfGrps{
    int ind = 0;
    __block BOOL occupied = NO;
    //rearrange
    NSMutableArray *plrViewInGrp = [[NSMutableArray alloc] init];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[PlayerUIView class]]) {
            PlayerUIView *playerView = subview;
            if (playerView.groupNum == numOfGrps && playerView.playerNum == numOfPlrs) {
                occupied = YES;
            }
            if (playerView.groupNum != -1 && playerView.playerNum != -1) {
                [plrViewInGrp addObject:playerView];
            }
        }
    }
    //if occupied find the first open spot
    if (occupied) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerNum" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        plrViewInGrp = [plrViewInGrp sortedArrayUsingDescriptors:sortDescriptors].mutableCopy;
        
        //sort plrViewinGrp according to playernum
        for (PlayerUIView *pv in plrViewInGrp) {
            if (pv.playerNum != ind) {
                //open position
                break;
            }
            ind ++;
        }
        //ind is the new position
    }else{
        ind = numOfPlrs;
    }
    float x = (self.colSize - playerWidth)/2 + self.colSize;
    self.draggedView.frame = CGRectMake(x+(ind * self.colSize), 100+(numOfGrps * spaceBetweenGroups),80,80);
    self.draggedView.playerNum = ind;
    self.draggedView.groupNum = numOfGrps;
    //change border color back
    for (UIView *subv in self.draggedView.subviews) {
        if (subv.tag == 1) {
            subv.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
            break;
        }
    }
    PlayerInGroup * groupP = [self convertTourneyP_to_GroupP: self.draggedView.player];
    groupP.index = [NSNumber numberWithInt:ind];
    
    return groupP;
}

- (PlayerInGroup *) convertTourneyP_to_GroupP:(PlayerInTourney *) playerInTourney{
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerInGroup" inManagedObjectContext:managedObjectContext];
//    PlayerInGroup *groupP = [[PlayerInGroup alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

    PlayerInGroup *groupP = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerInGroup" inManagedObjectContext:self.theTournamentContext];
    
    NSDictionary *attributes = [[NSEntityDescription entityForName:@"PlayerInTourney" inManagedObjectContext:self.theTournamentContext] attributesByName];
    for (NSString *attr in attributes) {
        [groupP setValue:[playerInTourney valueForKey:attr] forKey:attr];
    }
    
    return groupP;
}

- (void) addGrouping:(int)index xVal:(CGFloat)x yVal:(CGFloat)y {
    GroupUIView *groupView = [[GroupUIView alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width - x, 100)];
    //        groupView.backgroundColor = [UIColor lightGrayColor];
    UILabel *grouplab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width - x, 20)];
    NSNumber *groupNum = [NSNumber numberWithInt:index+1];
    grouplab.text = [NSString stringWithFormat:@"%@%@",@"Group ", groupNum.stringValue];
    grouplab.textColor = [UIColor whiteColor];
    grouplab.textAlignment = NSTextAlignmentCenter;
    grouplab.font = [UIFont fontWithName:mainFont size:17];
    [groupView addSubview:grouplab];
    
    UILabel *groupCountLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 130, 10, 20, 20)];
    groupCountLab.text = @"0";
    groupCountLab.textAlignment = NSTextAlignmentCenter;
    groupCountLab.textColor = [UIColor whiteColor];
    groupCountLab.font = [UIFont fontWithName:mainFont size:12];
    groupCountLab.layer.cornerRadius = groupCountLab.frame.size.width / 2;
    groupCountLab.clipsToBounds = YES;
    groupCountLab.layer.borderWidth = 1.0;
    groupCountLab.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    [groupView addSubview:groupCountLab];
    
    for (Competition *comp in self.roundMO.hasComp) {
        if ([comp.compType containsString: @"One-on-One"]) {
            UILabel *versusLab = [[UILabel alloc] initWithFrame:CGRectMake(groupView.frame.size.width - (self.colSize * 4), 27, self.colSize * 2, 20)];
            versusLab.text = @"Vs.";
            versusLab.textAlignment = NSTextAlignmentCenter;
            versusLab.textColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0];
            versusLab.font = [UIFont fontWithName:mainFont size:11];
            
            [groupView addSubview:versusLab];

            UILabel *versusLab2 = [[UILabel alloc] initWithFrame:CGRectMake(groupView.frame.size.width - (self.colSize * 2), 27, self.colSize * 2, 20)];
            versusLab2.text = @"Vs.";
            versusLab2.textAlignment = NSTextAlignmentCenter;
            versusLab2.textColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0];
            versusLab2.font = [UIFont fontWithName:mainFont size:11];
            
            [groupView addSubview:versusLab2];
        }
    }
    
    //core data
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:managedObjectContext];
//    Group *group = [[Group alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.theTournamentContext];
    group.groupid = [NSNumber numberWithInt:index+1];
    
    groupView.groupMO = group;
    
    [self.view addSubview:groupView];
    [self.groupsViewsAR addObject:groupView];
    
}

- (Scorecard *) populateScorecard {
    Course *course = self.roundMO.isOfCourse;
    
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Scorecard" inManagedObjectContext:managedObjectContext];
//    Scorecard *scorecard = [[Scorecard alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    Scorecard *scorecard = [NSEntityDescription insertNewObjectForEntityForName:@"Scorecard" inManagedObjectContext:self.theTournamentContext];
    //copy the values of course to scorecard
//    NSDictionary *courseDC = [course toDictionary:NO];
//
//    [scorecard populateFromDictionary:courseDC context:tempContext];
//    [self.theTournamentContext insertObject:scorecard];
    
    NSDictionary *attributes = [[NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.theTournamentContext] attributesByName];
    for (NSString *attr in attributes) {
        [scorecard setValue:[course valueForKey:attr] forKey:attr];
    }
//    for (Hole *hole in course.consistOf) {
//        [scorecard addConsistOfObject:hole];
//    }
    NSDictionary *holeAttr = [[NSEntityDescription entityForName:@"Hole" inManagedObjectContext:self.theTournamentContext] attributesByName];;
    for (Hole *h in course.consistOf) {
        
        Hole *sc_hole = [NSEntityDescription insertNewObjectForEntityForName:@"Hole" inManagedObjectContext:self.theTournamentContext];
        //copy values for holes
        for (NSString *attr in holeAttr) {
            [sc_hole setValue:[h valueForKey:attr] forKey:attr];
        }
        [scorecard addConsistOfObject:sc_hole];
    }
    scorecard.holeInd = [NSNumber numberWithInt:1];
    return  scorecard;
}

/*-------------------
 Exits
 --------------------*/

//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
//    if ([identifier isEqualToString:@"save"]) {
//        if ([self.playerViewsAR count] == 0){
//            [self save];
//            return YES;
//        }else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Incomplete Groups"
//                                                            message: @"Please place all the players in a group"
//                                                           delegate: nil
//                                                  cancelButtonTitle: @"OK"
//                                                  otherButtonTitles: nil];
//            [alert show];
//            return NO;
//        }
//    }else{
//        return NO;
//    }
//
//}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"save"]) {
//        [self save];
    }
}


@end
