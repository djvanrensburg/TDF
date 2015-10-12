//
//  TeamViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/22.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "TeamViewController.h"
#import "Team.h"
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "CoreDataUtil.h"
@interface TeamViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *teamIM;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTeamBT;
@property NSData *teampicDT;
@end

@implementation TeamViewController

/*-------------------
 Initiators
 --------------------*/
//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    // Do any additional setup after loading the view.
    self.teamIM.clipsToBounds = YES;
    self.teamIM.layer.cornerRadius = 8.0;
    self.teamIM.layer.borderWidth = 2.0;
    self.teamIM.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
    [self loadData];
}
/*-------------------
 Actions
 --------------------*/
- (IBAction)editPhoto:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    self.teampicDT = UIImageJPEGRepresentation(self.teamIM.image, 1);
}

- (void)add {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Team" inManagedObjectContext:managedObjectContext];
//    self.teamMO = [[Team alloc] initWithEntity:entity insertIntoManagedObjectContext:self.theTournamentContext];
    self.teamMO = [NSEntityDescription insertNewObjectForEntityForName:@"Team" inManagedObjectContext:self.theTournamentContext];
    self.teamMO.teamName = self.teamNameTI.text;
    if (self.teampicDT != nil) {
        self.teamMO.teamImage = self.teampicDT;
    }
}
/*-------------------
 Helpers
 --------------------*/

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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //    UIImage *selectedImage = [UIImage imageNamed:@"self.jpg"];
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    selectedImage = [CoreDataUtil scaleImage:selectedImage withFactor:1];
    self.teamIM.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.teampicDT = UIImageJPEGRepresentation(selectedImage, 1);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 if (sender != self.addTeamBT) {
     [self cancel];
            self.hidesBottomBarWhenPushed = NO;
 }else{
     [self add];
 }
}

- (void)cancel {
//    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
