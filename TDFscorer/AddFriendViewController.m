//
//  AddFriendViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/07.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "AddFriendViewController.h"
#import <CoreData/CoreData.h>
#import "Friend.h"
#import "CoreDataUtil.h"
@interface AddFriendViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveFriendBut;
@property NSData *myPicture;
@property (weak, nonatomic) IBOutlet UITextField *handicapTI;
//@property Friend *myFriend;
@end

@implementation AddFriendViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    self.photo.clipsToBounds = YES;
    self.photo.layer.cornerRadius = 8.0;
    self.photo.layer.borderWidth = 2.0;
    self.photo.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
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
    // Fetch the devices from persistent data store
    if (self.friendMO == nil) {
    }else{
        [self.nameTextField setText:[NSString stringWithFormat:@"%@", self.friendMO.friendName]];
        [self.emailTextField setText:[NSString stringWithFormat:@"%@", self.friendMO.email]];
        self.handicapTI.text = self.friendMO.handicap.stringValue;
        self.myPicture = self.friendMO.photo;
        self.photo.image = [UIImage imageWithData:self.myPicture];
    }
}

- (void)save {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (self.friendMO == nil) {
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:managedObjectContext];
//        self.friendMO = [[Friend alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];

        self.friendMO = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:managedObjectContext];
    }
    self.friendMO.friendName = self.nameTextField.text;
    self.friendMO.email = self.emailTextField.text;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *hc = [f numberFromString:self.handicapTI.text];
    self.friendMO.handicap = hc;
    self.friendMO.photo = self.myPicture;
    
//    [managedObjectContext insertObject:self.friendMO];
    NSError *error = nil;
    // Save the object to persistent store
    if (![managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UIImage *selectedImage = [UIImage imageNamed:@"self.jpg"];
    selectedImage = [CoreDataUtil scaleImage:selectedImage withFactor:0.7];
    selectedImage = info[UIImagePickerControllerEditedImage];
    self.photo.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.myPicture = UIImageJPEGRepresentation(selectedImage, 1);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.saveFriendBut) {
        [self cancel];
    }else{
        [self save];
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    [managedObjectContext deleteObject:self.friendMO];
}


@end
