//
//  LoginViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/15/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) invalidDetailAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Details Required"
           message: @"Please fill in the appropriate fields"
    preferredStyle:(UIAlertControllerStyleAlert)];

    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];

    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void) wrongUserAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Details"
           message:@"Could not find User"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void)loginUser {
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""]){
        [self invalidDetailAlert];
    }
    else {
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
                [self wrongUserAlert];
            } else {
                NSLog(@"User logged in successfully");
                [self performSegueWithIdentifier: @"loginSegue" sender: nil];
            }
        }];
    }
}

- (IBAction)loginButton:(id)sender {
    [self loginUser];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing: YES];
}

@end
