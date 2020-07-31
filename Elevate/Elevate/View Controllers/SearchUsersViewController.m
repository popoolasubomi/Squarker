//
//  SearchUsersViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "UsersCell.h"
#import "Parse/Parse.h"

@interface SearchUsersViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *filteredUsers;
@end

@implementation SearchUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self loadUsers];
}

-(void) loadUsers{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query orderByDescending: @"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.users = (NSMutableArray *) users;
            self.filteredUsers = self.users;
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UsersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"UsersCell" forIndexPath: indexPath];
    Post *post = self.users[indexPath.row];
    PFFileObject *imageData = [post objectForKey: @"image"];
    cell.profileImage.file = imageData;
    cell.usernameLabel.text = [NSString stringWithFormat: @"@%@",[post objectForKey: @"username"]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.users.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
