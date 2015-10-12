//
//  MainViewController.h
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/09.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
- (IBAction)unwindToHome:(UIStoryboardSegue *)segue;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@end
