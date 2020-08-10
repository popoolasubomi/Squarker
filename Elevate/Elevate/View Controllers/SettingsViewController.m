//
//  SettingsViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SettingsViewController.h"
#import "OAPFetcherSingleton.h"
#import "Parse/Parse.h"
#import "Post.h"
@import Parse;

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImage.layer.cornerRadius = 98;
    self.profileImage.layer.masksToBounds = YES;
    [self addTapGestureRecognizer];
}

- (void) errorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Details"
           message:@"Could not find User"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void) emptyFieldsAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Empty Field"
           message:@"Fill in empty fields"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void) pictureSource{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Camera"
           message:@"Choose Source"
    preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *cameraSource = [UIAlertAction actionWithTitle:@"Camera"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                           if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                                                               imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                           }
                                                           else {
                                                               NSLog(@"Camera 🚫 available so we will use photo library instead");
                                                               imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                               
                                                           }
                                                          [self presentViewController: imagePickerVC animated:YES completion:nil];
    }];
    
    UIAlertAction *librarySource = [UIAlertAction actionWithTitle: @"Photo Library"
                                                          style: UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                          [self presentViewController: imagePickerVC animated:YES completion:nil];
    }];
    
    [alert addAction: cameraSource];
    [alert addAction: librarySource];
    
    [self presentViewController: alert animated:YES completion:^{}];
}

-(void) addTapGestureRecognizer{
    UITapGestureRecognizer *cameraTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
    [self.profileImage addGestureRecognizer: cameraTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
}

-(void) didTapImage:(UITapGestureRecognizer *)sender{
    [self pictureSource];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = [self resizeImage: editedImage withSize: CGSizeMake(414, 414)];
    self.profileImage.layer.cornerRadius = 98;
    self.profileImage.layer.masksToBounds = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButton:(id)sender {
    if ([self.descriptionTextView isEqual: @""] || [self.nameTextView isEqual: @""]){
        [self emptyFieldsAlert];
    }
    else{
        OAPFetcherSingleton *singleton = [OAPFetcherSingleton sharedObject];
        [singleton fetchStatusLevel];
        [PFUser.currentUser setObject: self.nameTextView.text forKey: @"displayName"];
        [PFUser.currentUser setObject: self.descriptionTextView.text forKey: @"description"];
        PFFileObject *imageData = [Post getPFFileFromImage: self.profileImage.image];
        [PFUser.currentUser setObject: imageData forKey: @"image"];
        [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error){
                [self errorAlert];
            }
            else{
                NSLog(@"Saved Successfully");
                [self dismissViewControllerAnimated: YES completion: nil];
            }
        }];
    }
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing: YES];
}

@end
