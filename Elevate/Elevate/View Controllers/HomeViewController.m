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
#import "HomeCell.h"
#import "Post.h"
#import "Parse/Parse.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *filteredData;
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
    
    [self hideNavigationBarTitle];
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
    titleLabel.text = @"Timeline";
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText) {
        if (searchText.length != 0) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject[@"author"] containsString: searchText];
            }];
            self.filteredData = [self.posts filteredArrayUsingPredicate: predicate];
        }
        else {
            self.filteredData = self.posts;
        }
        [self.tableView reloadData];
    }
}

- (IBAction)logoutButton:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
       SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
       LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
       myDelegate.window.rootViewController = loginViewController;
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier: @"HomeCell"];
    Post *post = self.filteredData[indexPath.row];
    [cell setPost: post];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing: YES];
}

@end
