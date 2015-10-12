//
//  CoreDataUtil.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/18.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "CoreDataUtil.h"
#import "Friend.h"
#import "Self.h"
#import "PlayerInTourney.h"
#import <CoreData/CoreData.h>
#import "Round.h"
#import "Group.h"
#import "PlayerInGroup.h"
#import "CourseBase.h"
#import "Tournament.h"
#import "Team.h"
#import "Hole.h"

@implementation CoreDataUtil

+ (BOOL) addCourseToLib:(Tournament *)instance managedContext:(NSManagedObjectContext *)managedObjectContext{
    NSFetchRequest *fetchRequest;
    BOOL newCourseAdded = NO;
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CourseBase"];
    fetchRequest.includesSubentities = NO;
    CourseBase *newCourse;
    for (Round *round in instance.hasRounds) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courseName == %@ AND province == %@",round.isOfCourse.courseName,round.isOfCourse.province];
        [fetchRequest setPredicate:predicate];
        NSMutableArray *courseAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        if ([courseAR count] == 0) {
            //add new course
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CourseBase" inManagedObjectContext:managedObjectContext];
//            newCourse = [[CourseBase alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
            
            newCourseAdded = YES;
            Course *courseInRound = round.isOfCourse;
            newCourse = [NSEntityDescription insertNewObjectForEntityForName:@"CourseBase" inManagedObjectContext:managedObjectContext];
            NSDictionary *attributes = [[NSEntityDescription entityForName:@"CourseBase" inManagedObjectContext:managedObjectContext] attributesByName];
            for (NSString *attr in attributes) {
                [newCourse setValue:[courseInRound valueForKey:attr] forKey:attr];
            }
            NSDictionary *holeAttr = [[NSEntityDescription entityForName:@"Hole" inManagedObjectContext:managedObjectContext] attributesByName];;
            for (Hole *h in courseInRound.consistOf) {
                Hole *sc_hole = [NSEntityDescription insertNewObjectForEntityForName:@"Hole" inManagedObjectContext:managedObjectContext];
                //copy values for holes
                for (NSString *attr in holeAttr) {
                    [sc_hole setValue:[h valueForKey:attr] forKey:attr];
                }
                [newCourse addConsistOfObject:sc_hole];
            }

            [managedObjectContext insertObject:newCourse];
        }
    }
    
    if (newCourseAdded) {
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            //Respond to the error
        }
    }
    return newCourseAdded;
}

+ (UIImage *)scaleImage:(UIImage *)image withFactor:(float)factor {
        CGRect rect = CGRectMake(0, 0, 150*factor, 150*factor);
        CGSize newSize = rect.size;

    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    //CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

+ (BOOL) assignPicturesFromLib:(Tournament *)instance managedContext:(NSManagedObjectContext *)managedObjectContext{
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest;
    BOOL incompleteFriends = NO;
    Friend *newFriend;
    for (PlayerInTourney *player in instance.hasPlayers) {
        //find this player in friend list
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
        fetchRequest.includesSubentities = NO;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@",player.email];
        [fetchRequest setPredicate:predicate];
        NSMutableArray *friendsAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        if ([friendsAR count]==1) {
            Friend *friend = friendsAR[0];
            player.photo = friend.photo;
        }else{
            //not in friend list, but maybe it is me
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Self"];
            NSMutableArray *selfAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            Self *myself = selfAR[0];
            if ([myself.email isEqualToString:player.email]) {
                player.photo = myself.photo;
            }else{
                incompleteFriends = YES;
//                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedObjectContext];
//                newFriend = [[Friend alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
                
                newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:managedObjectContext];
                NSDictionary *attributes = [[NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedObjectContext] attributesByName];
                for (NSString *attr in attributes) {
                    [newFriend setValue:[player valueForKey:attr] forKey:attr];
                }

                [managedObjectContext insertObject:newFriend];
            }
        }
    }
    
    if (incompleteFriends) {
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            //Respond to the error
        }
    }
    
    //now players in Group
    for (Round * round in instance.hasRounds) {
        for (Group * group in round.hasGroups){
            for (PlayerInGroup *player in group.hasPlayers) {
                //find this player in friend list
                fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
                fetchRequest.includesSubentities = NO;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@",player.email];
                [fetchRequest setPredicate:predicate];
                NSMutableArray *friendsAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                if ([friendsAR count]==1) {
                    Friend *friend = friendsAR[0];
                    player.photo = friend.photo;
                }else{
                    //not in friend list, but maybe it is me
                    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Self"];
                    NSMutableArray *selfAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                    Self *myself = selfAR[0];
                    if ([myself.email isEqualToString:player.email]) {
                        player.photo = myself.photo;
                    }
                }
            }
        }
    }
    
    return incompleteFriends;
}
@end
