//
//  SpectatorSelViewController.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/05.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//
/* This class renders the ui for entering email addresses that can share in viewing a tournament*/
#import "SpectatorSelViewController.h"

@interface SpectatorSelViewController ()
@property (weak, nonatomic) IBOutlet UITextView *emailaddrTV;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIM;

@end

@implementation SpectatorSelViewController
- (IBAction)doShare:(id)sender {
//    self.emailAR = [self.emailaddrTV.text componentsSeparatedByString:@";"];
//    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)cancel:(id)sender {
    self.emailAR = nil;
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backgroundIM.layer.cornerRadius = 8.0;
    self.backgroundIM.clipsToBounds = YES;
    self.backgroundIM.layer.borderWidth = 2.0;
    self.backgroundIM.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.emailAR = [self.emailaddrTV.text componentsSeparatedByString:@";"];
    [self dismissViewControllerAnimated:YES completion:Nil];
}


@end
