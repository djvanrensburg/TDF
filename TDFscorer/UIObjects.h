//
//  UIObjects.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/25.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerUIView.h"
extern float const playerWidth;
@interface UIObjects : NSObject

+ (PlayerUIView *)getPlayerObj:(float)x_coord y_coord:(float) y_coord size:(float)size_fact player:(PlayerInTourney *)player;
+ (UIAlertView*)showWaitIndicator:(NSString *)title;
+ (UIAlertView*)showAlert:(NSString *)title message:(NSString *)message tag:(int)tag;

@end
