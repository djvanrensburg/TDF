//
//  Constants.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString * const adhoc = @"Ad hoc games";
//Gdrive keys
 NSString *const kKeychainItemName = @"Tour de Force";
 NSString *const kClientID = @"975845056051-vhv2p9oep2eci5huci5m5vobh0sd5p8e.apps.googleusercontent.com";
 NSString *const kClientSecret = @"kzBkiq10JQzxl1gfPVtkgl7P";

//font
NSString *const mainFont = @"Kohinoor Devanagari";

//Compitetion Types
NSString *const IDV_SP_2 = @"Individual Strokeplay (max +2)";
 NSString *const IDV_SP_3 = @"Individual Strokeplay (max +3)";
 NSString *const IDV_SP_4 = @"Individual Strokeplay (max +4)";
 NSString *const IDV_SP_5 = @"Individual Strokeplay (max +5)";
NSString *const IDV_SF = @"Individual Stableford";
NSString *const OO_SF_MP = @"One-on-One Stableford Matchplay";
NSString *const OO_SF = @"One-on-One Stableford";
 NSString *const OO_SP_MP = @"One-on-One Strokeplay Matchplay";
NSString *const OO_SP = @"One-on-One Strokeplay";
 NSString *const TM_COM_SF = @"Combined Stableford";
 NSString *const TM_COM_SF_MP = @"Combined Stableford Matchplay";
NSString *const TM_BB_SF = @"Betterball Stableford";
 NSString *const TM_BB_SF_MP = @"Betterball Stableford Matchplay";
 NSString *const TM_COM_SP = @"Combined Strokeplay";
 NSString *const TM_COM_SP_MP = @"Combined Strokeplay Matchplay";
NSString *const TM_BB_SP = @"Betterball Strokeplay";
 NSString *const TM_BB_SP_MP = @"Betterball Strokeplay Matchplay";
 NSString *const ALLIANCE = @"Fourball Alliance";

//Scoring Type
 NSString *const STABLEFORD = @"Stableford";
 NSString *const STROKEPLAY = @"Strokeplay";

NSString *const STABLEFORD_KEY = @"0";
NSString *const STROKEPLAY_KEY = @"1";

+(NSArray *)getCompetitionTypes:(NSString *)filter{
    NSArray *arr;
    if ([filter isEqualToString:STROKEPLAY]) {
        arr = [[NSArray alloc] initWithObjects:IDV_SP_2,IDV_SP_3,IDV_SP_4,IDV_SP_5,OO_SP_MP,OO_SP,TM_COM_SP, TM_COM_SP_MP, TM_BB_SP, TM_BB_SP_MP, nil];
    }else if([filter isEqualToString:STABLEFORD]){
        arr = [[NSArray alloc] initWithObjects:IDV_SF,OO_SF_MP,OO_SF,TM_COM_SF,TM_COM_SF_MP,TM_BB_SF,TM_BB_SF_MP, nil];
    }else{
        arr = [[NSArray alloc] initWithObjects:IDV_SP_2,IDV_SP_3,IDV_SP_4,IDV_SP_5,OO_SP_MP,OO_SP,TM_COM_SP, TM_COM_SP_MP, TM_BB_SP, TM_BB_SP_MP,IDV_SF,OO_SF_MP,OO_SF,TM_COM_SF,TM_COM_SF_MP,TM_BB_SF,TM_BB_SF_MP, nil];
    }
    arr = [arr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    return arr;
}

+(NSMutableDictionary *)getScoringTypes{
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:STABLEFORD,STABLEFORD_KEY,STROKEPLAY,STROKEPLAY_KEY,nil];
}

@end
