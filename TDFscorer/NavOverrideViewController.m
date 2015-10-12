//
//  NavOverrideViewController.m
//  TDFscorer
//
//  Created by DJ from iMac on 2015/08/12.
//  Copyright (c) 2015 DJ Janse van Rensburg. All rights reserved.
//

#import "NavOverrideViewController.h"
#import "CourseViewController.h"
#import "MainViewController.h"
#import "ProfileViewController.h"
#import "AssembleRoundViewController.h"
@interface NavOverrideViewController ()

@end

@implementation NavOverrideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)shouldAutorotate{
    return [[self.viewControllers lastObject] shouldAutorotate];
}
@end
