//
//  HomeViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/17/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "HomeViewController.h"
#import "OAPFetcherSingleton.h"
#import "DetailsViewController.h"
#import "UsersProfileViewController.h"
#import "HomeCell.h"
#import "Post.h"
#import "Parse/Parse.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, HomeCellDelegate>

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *filteredData;
@property (nonatomic, strong) NSMutableArray *friendNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    [[OAPFetcherSingleton sharedObject] fetchStatusLevel];
    [self showNavigationBarTitle];
    [self loadPosts];
}

- (void) hideNavigationBarTitle{
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void) showNavigationBarTitle{
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Elevate";
    titleLabel.font = [UIFont fontWithName: @"Didot" size: 20];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

-(void) loadPosts{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey: @"author"];
    [query orderByDescending: @"createdAt"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = (NSMutableArray *) posts;
            self.filteredData = self.posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) loadFriendsPosts{
    self.friendNames = [PFUser.currentUser objectForKey: @"friendNames"];
    if (!self.friendNames){
        self.friendNames = [NSMutableArray array];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey: @"author"];
    [query orderByDescending: @"createdAt"];
    [query whereKey: @"username" containedIn: self.friendNames];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = (NSMutableArray *) posts;
            self.filteredData = self.posts;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText) {
        searchText = [searchText lowercaseString];
        if (searchText.length != 0) {
            NSPredicate *namePredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject[@"author"][@"username"] containsString: searchText];
            }];
            
            self.filteredData = (NSMutableArray *) [self.posts filteredArrayUsingPredicate: namePredicate];
        }
        else {
            self.filteredData = self.posts;
        }
        [self.tableView reloadData];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier: @"HomeCell"];
    cell.delegate = self;
    Post *post = self.filteredData[indexPath.row];
    [cell setPost: post];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (void)homeCell:(nonnull HomeCell *)homeCell didTap:(nonnull Post *)post {
    [self performSegueWithIdentifier:@"detailsSegue" sender: post];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"detailsSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        DetailsViewController *detailsController = (DetailsViewController *)  navigationController.topViewController;
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.posts[indexPath.row];
        detailsController.post = post;
    } else if ([[segue identifier] isEqualToString: @"profileSegue"]){
          UINavigationController *navigationController = [segue destinationViewController];
        UsersProfileViewController *profileController = (UsersProfileViewController *)  navigationController.topViewController;
        profileController.post = sender;
        profileController.type = NO;
    }
}

@end
