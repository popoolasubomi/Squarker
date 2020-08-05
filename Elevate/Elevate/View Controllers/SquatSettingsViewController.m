//
//  SquatSettingsViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 8/3/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "SquatSettingsViewController.h"

@interface SquatSettingsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *timeSwitch;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISwitch *instructionSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (nonatomic, strong) NSMutableArray *possibleHeights;
@property (nonatomic) double heightValue;

@end

@implementation SquatSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildHeights];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

- (void) buildHeights{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.possibleHeights = [NSMutableArray array];
    for (int i = 4; i < 8; i++){
        for (int j = 0; j <= 11; j++){
            [self.possibleHeights addObject: @[@(i), @(j)]];
        }
    }
    NSString *height = [defaults objectForKey: @"Height"];
    if (!height){
        self.heightLabel.text = height;
    }
    [self.pickerView reloadAllComponents];
}

- (IBAction)sliderMoved:(id)sender {
    self.timeLabel.text = [NSString stringWithFormat: @"Time: %.f mins", self.slider.value];
}

- (IBAction)timeSwitchMoved:(id)sender {
    if (self.timeSwitch.on){
        self.slider.alpha = 0;
        self.timeLabel.text = [NSString stringWithFormat: @"Time: ?? mins"];
    } else{
        self.slider.alpha = 1;
        self.timeLabel.text = [NSString stringWithFormat: @"Time: %.f mins", self.slider.value];
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)saveButton:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble: self.heightValue forKey: @"Height"];
    
    if (self.timeSwitch.on){
        [defaults setInteger: 0 forKey: @"Time"];
    } else{
        NSString *timeSet = [NSString stringWithFormat: @"%.f", self.slider.value];
        int time = [timeSet intValue];
        [defaults setInteger: time forKey: @"Time"];
    }
    
    if (self.instructionSwitch.on){
        [defaults setBool: NO forKey: @"Instruction"];
        NSLog(@"me");
    } else{
        [defaults setBool: YES forKey: @"Instruction"];
    }
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.possibleHeights.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *height = self.possibleHeights[row];
    return [NSString stringWithFormat: @"%@ '%@", height[0], height[1]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSArray *height = self.possibleHeights[row];
    self.heightLabel.text = [NSString stringWithFormat: @"Height: %@ '%@", height[0], height[1]];
    
    double inches = [height[1] doubleValue];
    double feet = [height[0] doubleValue];
    
    double decimalHeight = inches / 12.0;
    self.heightValue = feet + decimalHeight;
}

@end
