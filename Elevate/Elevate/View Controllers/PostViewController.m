//
//  PostViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "PostViewController.h"
#import "HomeViewController.h"
#import "SceneDelegate.h"
#import "Post.h"

@interface PostViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *numberOfSquats;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *squatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *squatTime;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.numberOfSquats.text = [NSString stringWithFormat: @"%d", self.numSquats.intValue];
    self.squatTime.text = [NSString stringWithFormat: @"%d", self.totalTime.intValue];
    self.textView.delegate = self;
}

- (void) errorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Error"
           message:@"error making post"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

- (void) emptyFieldsAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Empty Field"
           message:@"Fill in the caption"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAlert = [UIAlertAction actionWithTitle:@"Ok"
                                                           style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction: okAlert];
    [self presentViewController: alert animated:YES completion:^{}];
}

-(void) goHome{
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    myDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticatedViewController"];
}

- (IBAction)shareButton:(id)sender {
    if ([self.textView.text isEqualToString: @""]){
        [self emptyFieldsAlert];
    } else{
        [Post postUserWithCaption: self.textView.text WithSquats: self.numSquats WithTime: self.totalTime withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error){
                NSLog(@"Error description: %@", error.localizedDescription);
                [self errorAlert];
            } else{
                NSLog(@"Upload was successful");
                [self goHome];
            }
        }];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect newFrame = textView.frame;
    newFrame.origin.y -= 150;
    
    [UIView animateWithDuration: 0.2 animations:^{
        self.numberOfSquats.alpha = 0;
        self.instructionLabel.alpha = 0;
        self.squatsLabel.alpha = 0;
        self.numberOfSquats.alpha = 0;
        self.postButton.alpha = 0;
        self.timeLabel.alpha = 0;
        self.squatTime.alpha = 0;
    }];
    
    [UIView animateWithDuration: 0.3 animations:^{
        self.textView.frame = newFrame;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    CGRect newFrame = textView.frame;
    newFrame.origin.y += 150;
    
    [UIView animateWithDuration: 0.3 animations:^{
        self.numberOfSquats.alpha = 1;
        self.instructionLabel.alpha = 1;
        self.squatsLabel.alpha = 1;
        self.numberOfSquats.alpha = 1;
        self.postButton.alpha = 1;
        self.timeLabel.alpha = 1;
        self.squatTime.alpha = 1;
    }];
    
    [UIView animateWithDuration: 0.2 animations:^{
        self.textView.frame = newFrame;
    }];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing: YES];
}

@end
