//
//  HKTableViewController.m
//  HealthKit
//
//  Created by ZawYeNaing on 2/8/18.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import "HKTableViewController.h"
#import <HealthKit/HealthKit.h>
#import "HKHealthKitManager.h"

@interface HKTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *txtDate;
@property (weak, nonatomic) IBOutlet UILabel *txtTime;

@property (weak, nonatomic) IBOutlet UITextField *txtCaffeine;
@property (weak, nonatomic) IBOutlet UITextField *txtCalcium;
@property (weak, nonatomic) IBOutlet UITextField *txtCarbonHydrates;
@property (weak, nonatomic) IBOutlet UITextField *txtChloride;
@property (weak, nonatomic) IBOutlet UITextField *txtChromium;

@end

@implementation HKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self updateCaffeineType];
}

- (void)updateCaffeineType {
    
    HKQuantityType *caffeineType = [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
    
    [[HKHealthKitManager sharedManager] mostRecentQuantitySampleOfType: caffeineType
                                                             predicate: nil
                                                            completion: ^(HKQuantity *mostRecentQuantity, NSError *error) {
                                                                
    if (!mostRecentQuantity) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _txtCaffeine.text = @"Not Available";
        });
        
    } else {
        
        // HKUnit *caffeintUnit = [HKUnit unit]
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"CaffeineType : %@", mostRecentQuantity);
            // _txtCaffeine.text = [mostRecentQuantity doubleValueForUnit: ];
        });
        
    }
                                                                
    }];
    
}

- (IBAction)SaveToHealthKit:(id)sender {
}


@end
