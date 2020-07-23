//
//  ProfileViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "ProfileViewController.h"
#import "HomeCell.h"
#import "Post.h"

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *displayName;
@property (weak, nonatomic) IBOutlet UILabel *statusRank;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *heartImage;
@property (weak, nonatomic) IBOutlet UIImageView *squatImage;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (weak, nonatomic) IBOutlet UILabel *numSquats;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *posts;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self populateView];
}

- (IBAction)changeSegment:(id)sender {
    if (self.segmentedController.selectedSegmentIndex == 0){
        self.displayLabel.text = @"My Timeline";
    } else{
        self.displayLabel.text = @"Friends";
    }
}


-(void) populateView{
    PFUser *user = PFUser.currentUser;
    self.usernameLabel.text = user.username;
    if ([user objectForKey: @"image"] != nil){
        self.displayName.text = [user objectForKey: @"displayName"];
        self.statusRank.text = [user objectForKey: @"status"];
        self.numLikes.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"likes"] intValue]];
        self.numSquats.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"squats"] intValue]];
    } else{
        self.displayName.alpha = 0;
        self.statusLabel.alpha = 0;
        self.statusRank.alpha = 0;
    }
}

-(void) loadPosts{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey: @"author"];
    [query orderByDescending: @"createdAt"];
    [query whereKey:@"author" equalTo: [PFUser currentUser]];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = (NSMutableArray *) posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier: @"settingsSegue" sender: nil];
}

- (IBAction)squatButton:(id)sender {
    [self performSegueWithIdentifier: @"squatSegue" sender: nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"HomeCell"];
    Post *post = self.posts[indexPath.row];
    [cell setPost: post];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

@end
