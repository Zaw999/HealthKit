//
//  StepCountViewController.m
//  HealthKit
//
//  Created by zawyenaing on 2018/07/31.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import "StepCountViewController.h"
#import "HKHealthKitManager.h"
#import <HealthKit/HealthKit.h>

@interface StepCountViewController ()
{
    NSMutableArray *step;
}
@end

@implementation StepCountViewController



- (IBAction)healthIntegrationButtonSwitch:(UISwitch *)sender {
    
    if(sender.isOn) {
        [[HKHealthKitManager sharedManager] requestAuthorization];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear: animated];
    
    [[HKHealthKitManager sharedManager] mostRecentQuantitySampleOfTypeStepCount:^(NSMutableArray *stepCountData) {
        step = stepCountData;
        [_TableView reloadData];
    }];
}

- (IBAction)reloadData:(id)sender {
    
    [[HKHealthKitManager sharedManager] mostRecentQuantitySampleOfTypeStepCount:^(NSMutableArray *stepCountData) {
        step = stepCountData;
        [_TableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return step.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    NSDictionary *dict = [step objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString = [formatter stringFromDate:dict[@"date"]];
    
    cell.textLabel.text = dateString;
    cell.detailTextLabel.text = dict[@"step_count"];
    
    return cell;
}
@end
