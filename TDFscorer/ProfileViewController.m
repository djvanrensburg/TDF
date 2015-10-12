//
//  ProfileViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/08.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "ProfileViewController.h"
#import <CoreData/CoreData.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "Self.h"
#import "Tournament.h"
#import "UIObjects.h"
#import "GDriveUtils.h"
#import "CoreDataUtil.h"
#import "Constants.h"

//static NSString *const kKeychainItemName = @"Tour de Force";
//static NSString *const kClientID = @"975845056051-vhv2p9oep2eci5huci5m5vobh0sd5p8e.apps.googleusercontent.com";
//static NSString *const kClientSecret = @"kzBkiq10JQzxl1gfPVtkgl7P";

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveProfile;
@property (weak, nonatomic) IBOutlet UITextField *myName;
@property (weak, nonatomic) IBOutlet UITextField *myEmail;
@property Self *myProfile;
@property (weak, nonatomic) IBOutlet UIPickerView *favTourneyPV;
@property NSData *myPicture;
@property (weak, nonatomic) IBOutlet UITextField *handicapTI;
@property (weak, nonatomic) IBOutlet UITextField *numToursTI;
@property (weak, nonatomic) IBOutlet UITextField *rankingTI;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property NSArray *touneysAR;
@property Tournament *favTourney;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property GDriveUtils *gDriveUtil;
@property (weak, nonatomic) IBOutlet UIButton *changeEmail;
@end

@implementation ProfileViewController
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated{
    self.hidesBottomBarWhenPushed = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.handicapTI.delegate = self;
    self.numToursTI.delegate = self;
    self.rankingTI.delegate = self;
    self.myName.delegate = self;
    self.myEmail.delegate = self;
    self.myEmail.enabled = YES;
        [self loadData];
    
    if ([self.touneysAR count] == 0) {
        [self.favTourneyPV setHidden:YES];
    }
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    self.photo.clipsToBounds = YES;
    self.photo.layer.cornerRadius = 8.0;
    self.photo.layer.borderWidth = 2.0;
    self.photo.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
    // Do any additional setup after loading the view.

}

- (void)keyboardWillShow:(NSNotification*)notification{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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

- (IBAction)changeProfile:(id)sender {
    [self.gDriveUtil revokeToken];
    self.myEmail.text = nil;
    [self logIntoGDrive];
}
/*-------------------
 Save & Load
 --------------------*/
- (void)loadData {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Self"];
    NSMutableArray *myProfileArr = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tournament"];
    self.touneysAR = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if ([self.touneysAR count] > 0) {
        self.favTourney = [self.touneysAR objectAtIndex:0];
    }
    if (myProfileArr.count > 0) {
        self.myProfile = [myProfileArr objectAtIndex:0];
        [self.myName setText:[NSString stringWithFormat:@"%@", [self.myProfile valueForKey:@"friendName"]]];
        [self.myEmail setText:[NSString stringWithFormat:@"%@", [self.myProfile valueForKey:@"email"]]];
        NSNumber *hc = [self.myProfile valueForKey:@"handicap"];
        self.handicapTI.text = hc.stringValue;
        NSNumber *ranking = self.myProfile.rankingPoints;
        self.rankingTI.text = ranking.stringValue;
        NSNumber *numTours = self.myProfile.numberOfTourneys;
        self.numToursTI.text = numTours.stringValue;
        self.myPicture = [self.myProfile valueForKey:@"photo"];
        self.photo.image = [UIImage imageWithData:self.myPicture];
    }
    self.gDriveUtil = [[GDriveUtils alloc]init:self];
    [self logIntoGDrive];
}

- (void)save {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (self.myProfile == nil) {
        // Create a new managed object
        self.myProfile = [NSEntityDescription insertNewObjectForEntityForName:@"Self" inManagedObjectContext:context];
    }
    [self.myProfile setValue:self.myName.text forKey:@"friendName"];
    [self.myProfile setValue:self.myEmail.text forKey:@"email"];
    [self.myProfile setValue:[f numberFromString:self.handicapTI.text] forKey:@"handicap"];
    NSNumber *numOfTour = [f numberFromString:self.numToursTI.text];
    if (numOfTour != nil) {
        self.myProfile.numberOfTourneys = numOfTour;
    }
    NSNumber *ranking = [f numberFromString:self.rankingTI.text];
    if (ranking != nil) {
        self.myProfile.rankingPoints = ranking;
    }
    if (self.favTourney.tournamentName != nil) {
        self.myProfile.favTournament = self.favTourney.tournamentName;
    }
    if (self.myPicture != nil) {
        [self.myProfile setValue:self.myPicture forKey:@"photo"];
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*-------------------
 Helpers
 --------------------*/
- (void) notifyOfGdriveComplete:(NSString *)crud object:(NSObject *)anyObject{
    self.myEmail.text = crud;
    NSLog(@"Logged in Username %@", crud);
}

- (void) logIntoGDrive{
    GTMOAuth2ViewControllerTouch *authController;
    if ([self.gDriveUtil isAuthorized]){
    }else{
        // Not yet authorized, request authorization and push the login UI onto the navigation stack.
        [self.navigationController pushViewController:authController = [self.gDriveUtil createAuthController] animated:YES];
    }
}
/*-------------------
 Alerts
 --------------------*/

/*-------------------
 Others
 --------------------*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/*-------------------
 Tables
 --------------------*/

/*-------------------
 PickerViews
 --------------------*/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    selectedImage = [CoreDataUtil scaleImage:selectedImage withFactor:1.5];
    self.photo.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.myPicture = UIImageJPEGRepresentation(selectedImage, 1);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.touneysAR == nil){
        return 0;
    }else{
        return self.touneysAR.count;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.touneysAR == nil){
        return @"empty";
    }else{
        Tournament *tourney = self.touneysAR[row];
        return tourney.tournamentName;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.favTourney = [self.touneysAR objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerCustomView = (id)view;
    UILabel *pickerViewLabel = (id)view;
    UIImageView *pickerImageView;
    
    if (!pickerCustomView) {
        pickerCustomView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        pickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 20.0f)];
        pickerViewLabel= [[UILabel alloc] initWithFrame:CGRectMake(37.0f, -5.0f,
                                                                   [pickerView rowSizeForComponent:component].width - 10.0f, [pickerView rowSizeForComponent:component].height)];
        [pickerCustomView addSubview:pickerImageView];
        [pickerCustomView addSubview:pickerViewLabel];
    }
    Tournament *tourney = self.touneysAR[row];
    
    pickerImageView.image = [UIImage imageWithData:tourney.icon];
    pickerImageView.clipsToBounds = YES;
    pickerImageView.layer.cornerRadius = 2.0;
    pickerImageView.layer.borderWidth = 1.0;
    pickerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    pickerViewLabel.backgroundColor = [UIColor clearColor];
    pickerViewLabel.text = tourney.tournamentName; // where therapyTypes[row] is a specific example from my code
    pickerViewLabel.font = [UIFont fontWithName:mainFont size:15];
    pickerViewLabel.textColor = [UIColor whiteColor];
    return pickerCustomView;
}
/*-------------------
 Functions
 --------------------*/

/*-------------------
 Exits
 --------------------*/
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (sender == self.saveProfile) {
        if ([self.myEmail.text isEqualToString:@""]) {
            [UIObjects showAlert:@"Missing data" message:@"Please complete all fields" tag:1];
            return NO;
        }else{
            return YES;
        }
    }else{
        return YES;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender != self.saveProfile) {
        [self cancel];
    }else{
        [self save];
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
