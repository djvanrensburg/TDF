//
//  GroupUIView.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/06/17.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Group.h"
@interface GroupUIView : UIView{
    NSMutableArray *players;
}

//@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, retain) Group *groupMO;
//@property (nonatomic, retain) NSMutableArray *placeHolderRects;
@end
