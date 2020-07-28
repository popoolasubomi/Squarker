//
//  ProgressViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/27/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "ProgressViewController.h"
#import "Parse/Parse.h"
#import "Elevate-Swift.h"
#import "Post.h"
@import Charts;

@interface ProgressViewController () <ChartViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lowGrowthLabel;
@property (weak, nonatomic) IBOutlet UILabel *highGrowthLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSquatLabel;
@property (weak, nonatomic) IBOutlet UILabel *squatLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segnmentedControl;
@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, strong) NSArray *squatsData;
@property (nonatomic, strong) NSDate *timeAgo;
@property (nonatomic, strong) NSArray *posts;

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lineChartView.delegate = self;
    self.lineChartView.backgroundColor = [UIColor colorWithRed: 256 green:256 blue:256 alpha:1];

    self.lineChartView.chartDescription.enabled = NO;
    self.lineChartView.pinchZoomEnabled = NO;
    self.lineChartView.dragEnabled = YES;
    [self.lineChartView setScaleEnabled:YES];
    self.lineChartView.legend.enabled = NO;
    self.lineChartView.xAxis.enabled = NO;
    self.lineChartView.rightAxis.enabled = NO;
    
    NSDate *now = [NSDate date];
    self.timeAgo = [now dateByAddingTimeInterval:-0*24*60*60];
    [self loadData];
}

- (IBAction)switchTimeFrame:(id)sender {
    if (self.segnmentedControl.selectedSegmentIndex == 0){
        NSDate *now = [NSDate date];
        self.timeAgo = [now dateByAddingTimeInterval:-0*24*60*60];
        [self loadData];
    } else if (self.segnmentedControl.selectedSegmentIndex == 1) {
        NSDate *now = [NSDate date];
        self.timeAgo = [now dateByAddingTimeInterval:-7*24*60*60];
        [self loadData];
    } else{
        NSDate *now = [NSDate date];
        self.timeAgo = [now dateByAddingTimeInterval:-31*24*60*60];
        [self loadData];
    }
}

- (void) populateGraph{
    ChartViewController *chartController = [[ChartViewController alloc] init];
    if (self.dates.count > 0){
        self.lineChartView.data = [chartController setChartWithDataPoints: self.dates values: self.squatsData];
    }else{
        self.lineChartView.data = nil;
    }
}

- (void) loadData{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey: @"author"];
    [query orderByDescending: @"createdAt"];
    [query whereKey: @"author" equalTo: [PFUser currentUser]];
    [query whereKey: @"createdAt" greaterThanOrEqualTo: self.timeAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = posts;
            [self populateView];
            }
     else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) populateView{
    double highestGrowth;
    double lowestGrowth;
    int totalSquats;
    
    NSMutableArray *dates = [NSMutableArray array];
    NSMutableArray *squatsData = [NSMutableArray array];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    
    if (self.posts.count == 1){
        Post *post = self.posts[0];
        
        highestGrowth = 0.0;
        lowestGrowth = 0.0;
        totalSquats = post.squats.intValue;
        
        NSString* date = [formatter stringFromDate: [post createdAt]];
        [dates addObject: date];
        [squatsData addObject: [NSNumber numberWithDouble: post.squats.doubleValue]];
    }
    else if (self.posts.count > 1){
        Post *upper = self.posts[1];
        Post *lower = self.posts[0];
        double percent;
        
        if (lower.squats.doubleValue != 0){
            percent = (upper.squats.doubleValue - lower.squats.doubleValue) * 100 / lower.squats.doubleValue;
        } else{
            percent = 0.0;
        }
        
        highestGrowth = percent;
        lowestGrowth = percent;
        totalSquats = lower.squats.intValue;
        
        NSString* date = [formatter stringFromDate: [lower createdAt]];
        [dates addObject: date];
        [squatsData addObject: [NSNumber numberWithDouble: lower.squats.doubleValue]];
        
        for (int i = 1; i < self.posts.count; i++){
            Post *upper = self.posts[i];
            Post *lower = self.posts[i-1];
            double percent = (upper.squats.doubleValue - lower.squats.doubleValue) * 100 / lower.squats.doubleValue;
            
            if (percent > highestGrowth){
                highestGrowth = percent;
            }
            if (percent < lowestGrowth){
                lowestGrowth = percent;
            }
            totalSquats += upper.squats.intValue;
            
            NSString* date = [formatter stringFromDate: [upper createdAt]];
            [dates addObject: date];
            [squatsData addObject: [NSNumber numberWithDouble: upper.squats.doubleValue]];
           }
    }else{
        totalSquats = 0;
        lowestGrowth = 0.0;
        highestGrowth = 0.0;
    }
    
    PFUser *user = [PFUser currentUser];
    NSNumber *squats = [user objectForKey: @"squats"];
    self.totalSquatLabel.text = [NSString stringWithFormat: @"Squats: %d", squats.intValue];
    self.squatLabel.text = [NSString stringWithFormat: @"Total Squats: %d", totalSquats];
    self.lowGrowthLabel.text = [NSString stringWithFormat: @"Lowest Growth: %.f %%", lowestGrowth];
    self.highGrowthLabel.text = [NSString stringWithFormat: @"Highest Growth: %.f %%", highestGrowth];
    
    self.dates = (NSArray *) dates;
    self.squatsData = (NSArray *) squatsData;

    [self populateGraph];
}

@end
