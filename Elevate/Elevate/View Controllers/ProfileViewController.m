//
//  ProfileViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "ProfileViewController.h"
#import "DetailsViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "HomeCell.h"
#import "Post.h"
@import Parse;

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, HomeCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
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
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendNames;
@property (nonatomic, strong) UIImageView *isFriendImage;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self populateView];
    }];
    
    [self loadPosts];
}

- (IBAction)changeSegment:(id)sender {
    if (self.segmentedController.selectedSegmentIndex == 0){
        [self loadPosts];
        self.displayLabel.text = @"My Timeline";
    } else{
        [self loadFriends];
        self.displayLabel.text = @"Friends";
    }
}


-(void) populateView{
    PFUser *user = [PFUser currentUser];
    self.usernameLabel.text = user.username;
    self.friends = [user objectForKey: @"friends"];
    self.friendNames = [user objectForKey: @"friendNames"];
    if (!self.friends){
        self.friends = [NSMutableArray array];
    }
    if ([user objectForKey: @"image"] != nil){
        self.displayName.text = [user objectForKey: @"displayName"];
        self.statusRank.text = [user objectForKey: @"status"];
        self.numLikes.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"likes"] intValue]];
        self.numSquats.text = [NSString stringWithFormat: @"%d", [[user objectForKey: @"squats"] intValue]];
        self.descriptionLabel.text = [user objectForKey: @"description"];
        PFFileObject *imageData = [user objectForKey: @"image"];
        self.profileImage.layer.cornerRadius = 72;
        self.profileImage.layer.masksToBounds = YES;
        self.profileImage.image = [UIImage imageNamed: @"download"];
        self.profileImage.file = imageData;
        [self.profileImage loadInBackground];
        [self constructIsFriendimage];
        [self addTapGestureRecognizer];
    } else{
        self.displayName.alpha = 0;
        self.statusLabel.alpha = 0;
        self.statusRank.alpha = 0;
        self.descriptionLabel.alpha = 0;
    }
}

-(void) constructIsFriendimage{
    PFUser *user = [PFUser currentUser];
    
    CGRect frame = self.profileImage.frame;
    frame.origin.x = frame.origin.x + frame.size.width - 37.5;
    frame.origin.y = frame.origin.y + frame.size.height - 37.5;
    frame.size.width = 40.0;
    frame.size.height = 40.0;
    
    self.isFriendImage = [[UIImageView alloc] init];
    if  (![self.friendNames containsObject: user.username]){
        self.isFriendImage.image = [UIImage imageNamed: @"icons8-add-60"];
    }else{
        self.isFriendImage.image = [UIImage imageNamed: @"icons8-checked-60"];
    }
    self.isFriendImage.frame = frame;
    [self.view addSubview: self.isFriendImage];
}

-(void) addTapGestureRecognizer{
    UITapGestureRecognizer *friendTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapAddImage:)];
    [self.isFriendImage addGestureRecognizer: friendTapGestureRecognizer];
    [self.isFriendImage setUserInteractionEnabled:YES];
}

-(void) didTapAddImage:(UITapGestureRecognizer *)sender{
    PFUser *user = [PFUser currentUser];
    if  (![self.friendNames containsObject: user.username]){
        [self.friends addObject: user];
        [self.friendNames addObject: user.username];
        [user setObject: self.friends forKey: @"friends"];
        [user setObject: self.friendNames forKey: @"friendNames"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.isFriendImage.image = [UIImage imageNamed: @"icons8-checked-60"];
            }
        }];
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

- (void) loadFriends{
    PFUser *user = PFUser.currentUser;
    self.friends = [user objectForKey: @"friends"];
    [self.tableView reloadData];
}

- (IBAction)logoutButton:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
       SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
       LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
       myDelegate.window.rootViewController = loginViewController;
    }];
}

- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier: @"settingsSegue" sender: nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"HomeCell"];
    if (self.segmentedController.selectedSegmentIndex == 0){
        cell.delegate = self;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"detailSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        DetailsViewController *detailsController = (DetailsViewController *)  navigationController.topViewController;
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[indexPath.row];
        detailsController.post = post;
    }
}

- (void)homeCell:(nonnull HomeCell *)homeCell didTap:(nonnull Post *)post {
    [self performSegueWithIdentifier: @"detailSegue" sender: nil];
}

@end
