//
//  UsersProfileViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "UsersProfileViewController.h"
#import "HomeCell.h"

@interface UsersProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *userProfileLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *heartImage;
@property (weak, nonatomic) IBOutlet UIImageView *squatImage;
@property (weak, nonatomic) IBOutlet UILabel *numLikes;
@property (weak, nonatomic) IBOutlet UILabel *numSquats;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusRank;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *posts;

@end

@implementation UsersProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self populateView];
    [self loadPosts];
}

-(void) populateView{
    PFUser *user = self.post[@"author"];
    self.usernameLabel.text = user.username;
    if ([user objectForKey: @"image"] != nil){
        self.displayNameLabel.text = [user objectForKey: @"displayName"];
        self.statusRank.text = [user objectForKey: @"status"];
        self.numLikes.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"likes"] intValue]];
        self.numSquats.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"squats"] intValue]];
        self.descriptionLabel.text = [user objectForKey: @"description"];
        PFFileObject *imageData = [user objectForKey: @"image"];
        self.profileImage.layer.cornerRadius = 72;
        self.profileImage.layer.masksToBounds = YES;
        self.profileImage.file = imageData;
        [self.profileImage loadInBackground];
    } else{
        self.displayNameLabel.alpha = 0;
        self.statusLabel.alpha = 0;
        self.statusRank.alpha = 0;
        self.descriptionLabel.alpha = 0;
    }
}

- (IBAction)changeSegment:(id)sender {
    if (self.segmentedController.selectedSegmentIndex == 0){
        [self loadPosts];
        self.displayLabel.text = @"Users Timeline";
    } else{
        [self loadFriends];
        self.displayLabel.text = @"Friends";
    }
}

-(void) loadPosts{
    PFUser *user = self.post[@"author"];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey: @"author"];
    [query orderByDescending: @"createdAt"];
    [query whereKey:@"author" equalTo: user];
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

- (void) loadFriends{
    PFUser *user = self.post[@"author"];
    self.friends = [user objectForKey: @"Friends"];
    [self.tableView reloadData];
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
    if (self.segmentedController.selectedSegmentIndex == 0){
        Post *post = self.posts[indexPath.row];
        [cell setPost: post];
    } else{
        PFUser *friend = self.friends[indexPath.row];
        [cell setFriends: friend];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

@end
