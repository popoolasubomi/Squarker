//
//  SearchUsersViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "UsersProfileViewController.h"
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
    
    self.searchBar.delegate = self;
    
    [self loadUsers];
    [self editCollectionViewCells];
}

-(void) editCollectionViewCells{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;

    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

-(void) loadUsers{
    PFQuery *query = [PFUser query];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText) {
        searchText = [searchText lowercaseString];
        if (searchText.length != 0) {
            NSPredicate *namePredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject[@"username"] containsString: searchText];
            }];
            
            self.users = (NSMutableArray *) [self.filteredUsers filteredArrayUsingPredicate: namePredicate];
        }
        else {
            self.users = self.filteredUsers;
        }
        [self.collectionView reloadData];
    }
}

- (IBAction)findOthers:(id)sender {
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UsersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"UsersCell" forIndexPath: indexPath];
    Post *post = self.users[indexPath.row];
    
    cell.profileImage.image = [UIImage imageNamed: @"download"];
    PFFileObject *imageData = [post objectForKey: @"image"];
    cell.profileImage.file = imageData;
    [cell.profileImage loadInBackground];
    cell.usernameLabel.text = [NSString stringWithFormat: @"@%@",[post objectForKey: @"username"]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.users.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell: tappedCell];
    Post *user = self.users[indexPath.row];
    UINavigationController *navigationController = [segue destinationViewController];
    UsersProfileViewController *profileController = (UsersProfileViewController *) navigationController.topViewController;
    profileController.post = user;
    profileController.type = true;
}


@end
