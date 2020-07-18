//
//  HomeViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/17/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)logoutButton:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
       SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
       LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
       myDelegate.window.rootViewController = loginViewController;
    }];
}


@end
