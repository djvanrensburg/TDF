//
//  UIObjects.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/25.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "UIObjects.h"
float const playerWidth = 60;
@implementation UIObjects

+ (PlayerUIView *)getPlayerObj:(float)x_coord y_coord:(float) y_coord size:(float)size_fact player:(PlayerInTourney *)player{
    
    PlayerUIView *playerView =[[PlayerUIView alloc] initWithFrame:CGRectMake(x_coord,y_coord,playerWidth * size_fact,80 * size_fact)];
    playerView.player = player;
    playerView.playerNum = -1;
    playerView.groupNum = -1;
    
    playerView.userInteractionEnabled = YES;
    //        playerView.backgroundColor = [UIColor grayColor];
    UILabel *playerName =[[UILabel alloc] initWithFrame:CGRectMake(0, 50 * size_fact, playerWidth * size_fact, 20 * size_fact)];
    playerName.textColor = [UIColor whiteColor];
    playerName.text = player.friendName;
    playerName.textAlignment = NSTextAlignmentCenter;
    playerName.font = [UIFont fontWithName:@"Kohinoor Devanagari" size:10*size_fact];
    
    UILabel *playerTeam =[[UILabel alloc] initWithFrame:CGRectMake(0, 70 * size_fact, playerWidth * size_fact, 10 )];
    playerTeam.textColor = [UIColor lightGrayColor];
    playerTeam.text = player.team;
    playerTeam.textAlignment = NSTextAlignmentCenter;
    playerTeam.font = [UIFont fontWithName:@"Kohinoor Devanagari" size:8];
    
    UIImageView *playerPhoto =[[UIImageView alloc] initWithFrame:CGRectMake(5,0,50 * size_fact,50 * size_fact)];
    playerPhoto.image=[UIImage imageWithData:player.photo];
    playerPhoto.layer.cornerRadius = playerPhoto.frame.size.width / 2;
    playerPhoto.clipsToBounds = YES;
    playerPhoto.layer.borderWidth = 2.0 * size_fact;
    playerPhoto.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    playerPhoto.tag = 1;
    
    [playerView addSubview:playerPhoto];
    [playerView addSubview:playerTeam];
    [playerView addSubview:playerName];

    return playerView;
}

// Helper for showing a wait indicator in a popup
+ (UIAlertView*)showWaitIndicator:(NSString *)title{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

+ (UIAlertView*)showAlert:(NSString *)title message:(NSString *)message tag:(int)tag{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: nil
                             otherButtonTitles: @"OK", nil];
    alert.tag = tag;
    [alert show];
    return alert;
}
@end
