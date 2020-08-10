//
//  SignUpViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/15/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

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

- (void) signUpError{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"SignUp Error"
           message: @"Unsucessful SignUp"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void)registerUser {
    if ([self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""] || [self.emailField.text isEqual:@""]){
        [self invalidDetailAlert];
    }
    else{
        NSLog(@"%@", self.usernameField.text);
        PFUser *newUser = [PFUser user];
        newUser.username = [self.usernameField.text lowercaseString];
        newUser.email = self.emailField.text;
        newUser.password = self.passwordField.text;
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"MEABC@");
                NSLog(@"Error: %@", error.localizedDescription);
                [self signUpError];
            } else {
                NSLog(@"User registered successfully");
                [self performSegueWithIdentifier: @"loginSegue" sender: nil];
            }
        }];
    }
}


- (IBAction)registerButton:(id)sender {
    [self registerUser];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing: YES];
}

@end
