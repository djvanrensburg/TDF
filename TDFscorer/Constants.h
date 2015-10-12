//
//  Constants.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/06.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const adhoc;

extern NSString *const kKeychainItemName;
extern NSString *const kClientID;
extern NSString *const kClientSecret;

extern NSString *const mainFont;
//ind
extern NSString *const IDV_SP_2;
extern NSString *const IDV_SP_3;
extern NSString *const IDV_SP_4 ;
extern NSString *const IDV_SP_5 ;
extern NSString *const IDV_SF;
//o-o
extern NSString *const OO_SP_MP ;
extern NSString *const OO_SF_MP;
extern NSString *const OO_SP;
extern NSString *const OO_SF;
//team
extern NSString *const TM_COM_SF ;
extern NSString *const TM_COM_SF_MP ;
extern NSString *const TM_BB_SF;
extern NSString *const TM_BB_SF_MP ;
extern NSString *const TM_COM_SP ;
extern NSString *const TM_COM_SP_MP ;
extern NSString *const TM_BB_SP;
extern NSString *const TM_BB_SP_MP ;
extern NSString *const ALLIANCE ;

////keys
//extern NSString *const IDV_SP_2_key;
//extern NSString *const IDV_SP_3_key;
//extern NSString *const IDV_SP_4_key ;
//extern NSString *const IDV_SP_5_key ;
//extern NSString *const IDV_SF_key;
//
//extern NSString *const OO_SF_MP_key;
//extern NSString *const OO_SP_MP_key ;
//extern NSString *const OO_SF_key;
//extern NSString *const OO_SP_key ;
//
//extern NSString *const TM_COM_SF_key ;
//extern NSString *const TM_COM_SF_MP_key ;
//extern NSString *const TM_BB_SF_key;
//extern NSString *const TM_BB_SF_MP_key ;
//extern NSString *const TM_COM_SP_key ;
//extern NSString *const TM_COM_SP_MP_key ;
//extern NSString *const TM_BB_SP_key;
//extern NSString *const TM_BB_SP_MP_key ;
//extern NSString *const ALLIANCE_key ;

//Scoring Type
extern NSString *const STABLEFORD;
extern NSString *const STROKEPLAY;

@interface Constants : NSObject
@property NSMutableDictionary *competitionTypes;

+(NSArray *)getCompetitionTypes:(NSString *)filter;
+(NSMutableDictionary *)getScoringTypes;

@end
