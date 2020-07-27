//
//  ProgressViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/27/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "ProgressViewController.h"
#import "Elevate-Swift.h"
@import Charts;

@interface ProgressViewController ()

@property (weak, nonatomic) IBOutlet LineChartView *lineChartView;
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, strong) NSArray *squatsData;

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dates = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun"];
    self.squatsData = @[@(20.0), @(4.0), @(6.0), @(3.0), @(12.0), @(16.0)];
    
    ChartViewController *chartController = [[ChartViewController alloc] init];
    self.lineChartView.data = [chartController setChartWithDataPoints: self.dates values: self.squatsData];
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
