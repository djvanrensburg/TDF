//
//  CourseViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/05/26.
//  Copyright (c) 2015 DJ. All rights reserved.
//

#import "CourseViewController.h"
#import <CoreData/CoreData.h>
#import "ParUITextField.h"
#import "Hole.h"
#import "StrokeUITextField.h"
#import "Constants.h"
#import "CoreDataUtil.h"

@interface CourseViewController ()

@property (weak, nonatomic) IBOutlet UITextField *courseNameTI;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addCourseBT;
@property StrokeUITextField *strokeTI;
@property (weak, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UIView *lefPanelVW;
@property (weak, nonatomic) IBOutlet UIView *rightPanelVW;

@property (weak, nonatomic) IBOutlet UITextField *stroke1TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke2TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke3TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke4TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke5TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke6TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke7TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke8TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke9TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke10TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke11TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke12TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke13TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke14TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke15TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke16TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke17TI;
@property (weak, nonatomic) IBOutlet UITextField *stroke18TI;

@property (weak, nonatomic) IBOutlet UITextField *par1T1;
@property (weak, nonatomic) IBOutlet UITextField *par2T1;
@property (weak, nonatomic) IBOutlet UITextField *par3TI;
@property (weak, nonatomic) IBOutlet UITextField *par4TI;
@property (weak, nonatomic) IBOutlet UITextField *par5TI;
@property (weak, nonatomic) IBOutlet UITextField *par6TI;
@property (weak, nonatomic) IBOutlet UITextField *par7TI;
@property (weak, nonatomic) IBOutlet UITextField *par8TI;
@property (weak, nonatomic) IBOutlet UITextField *par9TI;
@property (weak, nonatomic) IBOutlet UITextField *par10TI;
@property (weak, nonatomic) IBOutlet UITextField *par11TI;
@property (weak, nonatomic) IBOutlet UITextField *par12TI;
@property (weak, nonatomic) IBOutlet UITextField *par13TI;
@property (weak, nonatomic) IBOutlet UITextField *par14TI;
@property (weak, nonatomic) IBOutlet UITextField *par15TI;
@property (weak, nonatomic) IBOutlet UITextField *par16TI;
@property (weak, nonatomic) IBOutlet UITextField *par17TI;
@property (weak, nonatomic) IBOutlet UITextField *par18TI;

@property (weak, nonatomic) IBOutlet UIImageView *coursePic;
@property NSData *coursePicDat;
@property (weak, nonatomic) IBOutlet UITextField *regionTI;
@property (weak, nonatomic) IBOutlet UIButton *deleteBut;

//@property (weak, nonatomic) IBOutlet UIView *leftView;
//@property (weak, nonatomic) IBOutlet UIView *rightView;
//@property (weak, nonatomic) IBOutlet UIScrollView *leftScroll;
//@property UIScrollView *leftScrollV;
//@property (weak, nonatomic) IBOutlet UIScrollView *rightScroll;
@property BOOL isCollapse;
@property BOOL isFirstTime;
@property BOOL isWorkDone;
@property  ParUITextField *parTI;
@end

@implementation CourseViewController
/*-------------------
 Initiators
 --------------------*/
-(BOOL)shouldAutorotate{
    return NO;
}

//- (NSManagedObjectContext *)managedObjesctContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirstTime = YES;
    
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background-2"]]];
    //    if (self.courseMO != nil) {
    //        [self loaddata];
    //    }
    self.coursePic.clipsToBounds = YES;
    self.coursePic.layer.cornerRadius = 8.0;
    self.coursePic.layer.borderWidth = 2.0;
    self.coursePic.layer.borderColor = [UIColor colorWithRed:0.576 green:0.86 blue:0.094 alpha:1.0].CGColor;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidShow:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidHide:)
//                                                 name:UIKeyboardDidHideNotification
//                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated{
//    if (self.isFirstTime) {
////        [self addHoles:self.lefPanelVW isleft:YES];
////        [self addHoles:self.rightPanelVW isleft:NO];
//        self.isFirstTime = NO;
//    }
    if (self.courseMO != nil) {
        [self loaddata];
    }else{
        [self.deleteBut setHidden:YES];
    }
}

//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    if ((textField.tag >= 6 && textField.tag <= 9) || (textField.tag >= 15 && textField.tag <= 18)) {
//        self.isCollapse = YES;
//        self.isWorkDone = NO;
//    }
//}
//
- (void)keyboardWillShow:(NSNotification*)notification{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//- (void) addHoles:(UIView *) panel isleft:(BOOL)isleft{
//    // draw holes
//    UILabel *holeLab = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, 34, 24)];
//    holeLab.text = @"Hole";
//    holeLab.font = [UIFont fontWithName:mainFont size:16];
//    holeLab.textColor = [UIColor whiteColor];
//    [panel addSubview:holeLab];
//    
//    UILabel *strokeLab = [[UILabel alloc]initWithFrame:CGRectMake(53, 0, 50, 24)];
//    strokeLab.text = @"Stroke";
//    strokeLab.font = [UIFont fontWithName:mainFont size:16];
//    strokeLab.textColor = [UIColor whiteColor];
//    [panel addSubview:strokeLab];
//    
//    UILabel *parLab = [[UILabel alloc]initWithFrame:CGRectMake(55 + 53, 0, 25, 24)];
//    parLab.text = @"Par";
//    parLab.font = [UIFont fontWithName:mainFont size:16];
//    parLab.textColor = [UIColor whiteColor];
//    [panel addSubview:parLab];
//    
//    UIView *moveablePanel = [[UIView alloc]initWithFrame:CGRectMake(panel.frame.origin.x,panel.frame.origin.y, panel.frame.size.width, panel.frame.size.height)];
//    moveablePanel.tag = isleft?11:22;
//    [self.view addSubview:moveablePanel];
//    
//    int endInd = 1+9;
//    int tag;
//    for (int i=1; i<endInd; i++) {
////        if (y+i*26 > 0) {
//            tag = isleft?i:9 + i;
//            UILabel *holenum = [[UILabel alloc]initWithFrame:CGRectMake(16, i * 26, 25, 24)];
//            holenum.text = [NSNumber numberWithInt:tag].stringValue;
//            holenum.font = [UIFont fontWithName:mainFont size:16];
//            holenum.textColor = [UIColor whiteColor];
//            holenum.tag = tag;
//            [moveablePanel addSubview:holenum];
//            
//            self.strokeTI = [[StrokeUITextField alloc] initWithFrame:CGRectMake(58,i * 26, 25, 24)];
//            self.strokeTI.font = [UIFont fontWithName:mainFont size:14];
//            self.strokeTI.tag = tag;
//            self.strokeTI.backgroundColor = [UIColor whiteColor];
//            self.strokeTI.layer.cornerRadius = 8.0;
//            self.strokeTI.clipsToBounds = YES;
//            self.strokeTI.keyboardType = UIKeyboardTypeNumberPad;
//            self.strokeTI.textAlignment = NSTextAlignmentCenter;
//            self.strokeTI.delegate = self;
//            [moveablePanel addSubview:self.strokeTI];
//            
//            self.parTI = [[ParUITextField alloc] initWithFrame:CGRectMake(58 + 50, i * 26, 25, 24)];
//            self.parTI.font = [UIFont fontWithName:mainFont size:14];
//            self.parTI.tag = tag;
//            self.parTI.backgroundColor = [UIColor whiteColor];
//            self.parTI.layer.cornerRadius = 8.0;
//            self.parTI.clipsToBounds = YES;
//            self.parTI.keyboardType = UIKeyboardTypeNumberPad;
//            self.parTI.textAlignment = NSTextAlignmentCenter;
//            self.parTI.delegate = self;
//            [moveablePanel addSubview:self.parTI];
////        }
//    }
//}
/*-------------------
 Actions
 --------------------*/
- (IBAction)selectPicture:(id)sender {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
- (IBAction)deleteCours:(id)sender {
    if (self.courseMO != nil) {
//        NSManagedObjectContext *deleteCourseContext = [self managedObjectContext];
        [self.theCourseContext deleteObject:self.courseMO];
        NSError *error = nil;
        // Save the object to persistent store
        if (![self.theCourseContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [self performSegueWithIdentifier:@"back" sender:self];
    }
}

/*-------------------
 Save & Load
 --------------------*/
- (void) loaddata{
    self.courseNameTI.text = self.courseMO.courseName;
    self.coursePicDat = self.courseMO.picture;
    self.coursePic.image = [UIImage imageWithData:self.coursePicDat];
    self.regionTI.text = self.courseMO.province;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holeNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *holeARR = [self.courseMO.consistOf allObjects];
    holeARR = [holeARR sortedArrayUsingDescriptors:sortDescriptors];
    for (UIView *scrollview in self.view.subviews) {
        if (scrollview.tag == 99) {
            for (UIView *contentView in scrollview.subviews) {
                if (contentView.tag == 88) {
                    for (UIView *panelview in contentView.subviews) {
                        if (panelview.tag == 11 || panelview.tag == 22) {
                            for (UIView *subUIEl in panelview.subviews) {
                                if ([subUIEl isKindOfClass:[ParUITextField class]]) {
                                    ParUITextField *parTI = (ParUITextField *)subUIEl;
                                    if ([holeARR count] != nil && [holeARR count]>=parTI.tag-1) {
                                        Hole *hole = holeARR[parTI.tag-1];
                                        parTI.text = hole.par.stringValue;
                                    }else{
                                        parTI.text = @"0";
                                    }
                                }else if([subUIEl isKindOfClass:[StrokeUITextField class]]){
                                    StrokeUITextField *strokeTI = (StrokeUITextField *)subUIEl;
                                    if ([holeARR count]!= nil && [holeARR count]>=strokeTI.tag-1) {
                                        Hole *hole = holeARR[strokeTI.tag-1];
                                        strokeTI.text = hole.stroke.stringValue;
                                    }else{
                                        strokeTI.text = @"0";
                                    }
                                }
                            }
                        }
                    }
                    break;
                }
            }
            break;
        }
    }

}

- (void)add {
    Hole *hole;
    BOOL isUpdate = NO;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
//    NSManagedObjectContext *addCourseContext = [self managedObjectContext];
//    NSManagedObjectContext *managedObjectContext2 = [self managedObjectContext];
    if (self.courseMO == nil) {
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CourseBase" inManagedObjectContext:managedObjectContext];
//        self.courseMO = [[CourseBase alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext2];

        self.courseMO = [NSEntityDescription insertNewObjectForEntityForName:@"CourseBase" inManagedObjectContext:self.theCourseContext];
    }else{
        isUpdate = YES;
    }
    
    self.courseMO.courseName = self.courseNameTI.text;
    self.courseMO.picture = self.coursePicDat;
    self.courseMO.province = self.regionTI.text;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"holeNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *holesAR = [self.courseMO.consistOf allObjects];
    NSArray *holesSortedAR = [holesAR sortedArrayUsingDescriptors:sortDescriptors];
    
    for (UIView *scrollview in self.view.subviews) {
        if (scrollview.tag == 99) {
            for (UIView *contentView in scrollview.subviews) {
                if (contentView.tag == 88) {
                    for (UIView *panelView in contentView.subviews) {
                        if (panelView.tag == 11 || panelView.tag == 22) {
                            for (UIView *subUIEl in panelView.subviews) {
                                if ([subUIEl isKindOfClass:[ParUITextField class]]) {
                                    ParUITextField *parTI = (ParUITextField *)subUIEl;
                                    if ([holesSortedAR count] == 0) {
//                                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hole" inManagedObjectContext:managedObjectContext];
//                                        Hole *hole = [[Hole alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext2];
                                        hole = [NSEntityDescription insertNewObjectForEntityForName:@"Hole" inManagedObjectContext:self.theCourseContext];
                                        hole.holeNumber = [NSNumber numberWithInt:parTI.tag];
                                        [self.courseMO addConsistOfObject:hole];
                                    }else{
                                        hole = holesSortedAR[parTI.tag-1];
                                    }
                                    hole.par = [f numberFromString:parTI.text];
                                }
                            }
                        }
                    }
                    break;
                }
            }
            break;
        }
    }

    holesAR = [self.courseMO.consistOf allObjects];
    holesSortedAR = [holesAR sortedArrayUsingDescriptors:sortDescriptors];
    
    for (UIView *scrollview in self.view.subviews) {
        if (scrollview.tag == 99) {
            for (UIView *contentView in scrollview.subviews) {
                if (contentView.tag == 88) {
                    for (UIView *panelView in contentView.subviews) {
                        if (panelView.tag == 11 || panelView.tag == 22) {
                            for (UIView *subUIEl in panelView.subviews) {
                                if ([subUIEl isKindOfClass:[StrokeUITextField class]]){
                                    StrokeUITextField *strokeTI = (StrokeUITextField *)subUIEl;
                                    Hole *hole = holesSortedAR[strokeTI.tag-1];
                                    hole.stroke = [f numberFromString:strokeTI.text];
                                }
                            }
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
//    if (!isUpdate) {
//        [self.theCourseContext insertObject:self.courseMO];
//    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![self.theCourseContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    for (Hole *h in self.courseMO.consistOf) {
        NSLog(@"hole number: %@", h.holeNumber.stringValue);
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
    UIImage *selectedImage = [UIImage imageNamed:@"course.jpg"];
    selectedImage = [CoreDataUtil scaleImage:selectedImage withFactor:0.8];
    selectedImage = info[UIImagePickerControllerEditedImage];
    self.coursePic.image = selectedImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.coursePicDat = UIImageJPEGRepresentation(selectedImage, 1);
    self.courseMO.picture = self.coursePicDat;
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
     if ([segue.identifier isEqualToString:@"save"]) {
         [self add];
     }else if([segue.identifier isEqualToString:@"back"]){
         
     }else{
         [self cancel];
     }
 }
 
 - (void)cancel {
 }

@end
