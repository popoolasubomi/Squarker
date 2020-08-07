//
//  UsersProfileViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "UsersProfileViewController.h"
#import "DetailsViewController.h"
#import "HomeCell.h"
#import "Friend.h"
#import "Post.h"

@interface UsersProfileViewController () <UITableViewDelegate, UITableViewDataSource, HomeCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *squatImage;
@property (weak, nonatomic) IBOutlet UILabel *numPosts;
@property (weak, nonatomic) IBOutlet UILabel *numSquats;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusRank;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PFUser *postUser;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendNames;
@property (nonatomic, strong) NSMutableArray *currentUserFriends;
@property (nonatomic, strong) NSMutableArray *currentUserFriendNames;
@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) UIImageView *isFriendImage;

@end

@implementation UsersProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self populateView];
        [self loadPosts];
    }];
}

-(void) populateView{
    if (self.type == true){
        self.postUser = (PFUser *) self.post;
    }else{
        self.postUser = self.post[@"author"];
    }
    self.usernameLabel.text = [NSString stringWithFormat: @"@%@", self.postUser.username];
    self.friends = [self.postUser objectForKey: @"friends"];
    self.friendNames = [self.postUser objectForKey: @"friendNames"];
    if (!self.friends){
        self.friends = [NSMutableArray array];
        self.friendNames = [NSMutableArray array];
    }
    self.currentUserFriendNames = [[PFUser currentUser] objectForKey: @"friendNames"];
    self.currentUserFriends = [[PFUser currentUser] objectForKey: @"friends"];
    if (!self.currentUserFriends){
        self.currentUserFriends = [NSMutableArray array];
        self.currentUserFriendNames = [NSMutableArray array];
    }
    if ([self.postUser objectForKey: @"image"] != nil){
        self.displayNameLabel.text = [self.postUser objectForKey: @"displayName"];
        self.statusRank.text = [self.postUser objectForKey: @"status"];
        self.numPosts.text = [NSString stringWithFormat: @"Stories: %d", [[self.postUser objectForKey: @"postCount"] intValue]];
        self.numSquats.text = [NSString stringWithFormat: @"%d", [[self.postUser objectForKey: @"squats"] intValue]];
        self.descriptionLabel.text = [self.postUser objectForKey: @"description"];
        PFFileObject *imageData = [self.postUser objectForKey: @"image"];
        self.profileImage.layer.cornerRadius = 72;
        self.profileImage.layer.masksToBounds = YES;
        self.profileImage.image = [UIImage imageNamed: @"download"];
        self.profileImage.file = imageData;
        [self.profileImage loadInBackground];
        [self constructIsFriendimage];
        [self addTapGestureRecognizer];
    } else{
        self.displayNameLabel.alpha = 0;
        self.statusLabel.alpha = 0;
        self.statusRank.alpha = 0;
        self.descriptionLabel.alpha = 0;
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
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

-(void) constructIsFriendimage{
    
    CGRect frame = self.profileImage.frame;
    frame.origin.x = frame.origin.x + frame.size.width - 37.5;
    frame.origin.y = frame.origin.y + frame.size.height - 37.5;
    frame.size.width = 40.0;
    frame.size.height = 40.0;
    
    self.isFriendImage = [[UIImageView alloc] init];
    if  (![self.currentUserFriendNames containsObject: self.post.username]){
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
    if  (![self.currentUserFriendNames containsObject: self.post.username]){
        NSDictionary *friend = [[Friend alloc] BuildWithPFUser: self.postUser];
        [self.currentUserFriends addObject: friend];
        [self.currentUserFriendNames addObject: self.postUser.username];
        [user setObject: self.currentUserFriends forKey: @"friends"];
        [user setObject: self.currentUserFriendNames forKey: @"friendNames"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded){
                self.isFriendImage.image = [UIImage imageNamed: @"icons8-checked-60"];
            }
        }];
    }
}


-(void) loadPosts{
    PFUser *user;
    if (self.type == true){
        user = (PFUser *) self.post;
    }else{
        user = self.post[@"author"];
    }
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
    PFUser *user;
    if (self.type == true){
        user = (PFUser *) self.post;
    }else{
        user = self.post[@"author"];
    }
    NSArray *friends = [user objectForKey: @"friends"];
    self.friends = [Friend friendsWithArray: friends];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"HomeCell"];
    if (self.segmentedController.selectedSegmentIndex == 0){
        Post *post = self.posts[indexPath.row];
        cell.delegate = self;
        [cell setPost: post];
    } else{
        Friend *friend = self.friends[indexPath.row];
        [cell setFriends: friend];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedController.selectedSegmentIndex == 0){
        return self.posts.count;
    } else{
        return self.friends.count;
    }
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
