//
//  SearchUsersViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "Parse/Parse.h"

@interface SearchUsersViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *filteredUsers;
@end

@implementation SearchUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) loadUsers{
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    [query orderByDescending: @"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.users = (NSMutableArray *) users;
            self.filteredUsers = self.users;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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
