//
//  ViewController.m
//  HealthKit
//
//  Created by Zaw Ye Naing on 2018/02/03.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//
#import "HKHealthKitManager.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)healthIntegrationButtonSwitch:(UISwitch *)sender {
    
    if(sender.isOn) {
        [[HKHealthKitManager sharedManager] requestAuthorization];
    } else {
        
    }
}

- (IBAction)readDateOfBirth:(id)sender {
    
    NSDateComponents *birthDate = [[HKHealthKitManager sharedManager] readBirthDate];
    
    if(birthDate == nil) {
        return;
    }
    _lblDateOfBirth.text = [NSString stringWithFormat: @"%ld/%ld/%ld", [birthDate year], [birthDate month], [birthDate day]];
    
}
- (IBAction)writeBodyWeight:(id)sender {
    
    [self.view endEditing: YES];
    
//    [[HKHealthKitManager sharedManager] saveHKSample: _txtBodyWeight.text.floatValue heightSample: _txtBodyHeight.text.floatValue];
    
    [[HKHealthKitManager sharedManager] saveHKSample: _txtBodyWeight.text.floatValue heightSample: _txtBodyHeight.text.floatValue withCompletion: ^(BOOL result){
        if (result) {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NULL
                                                                           message:@"Saved to HealthKit"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];

    
    
    
}

@end
