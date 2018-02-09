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
- (IBAction)requestAuthorization:(UISwitch *)sender {
    
    if(sender.isOn) {
        [[HKHealthKitManager sharedManager] requestAuthorization];
    } else {
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self updateUsersHeightLabel];
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
        NSLog(@"CaffeineType : %@", mostRecentQuantity);
        //HKUnit *caffeintUnit = [HKUnit unitFromString: @"mg/dl"];
        // HKQuantity *quantity = [mostRecentQuantity doubleValueForUnit: caffeint];
        HKUnit *caffeintUnit = [HKUnit gramUnit];
        double caffeine = [mostRecentQuantity doubleValueForUnit: caffeintUnit];
        double meterValue = caffeine * 1000;
        NSLog(@"CaffeineType : %d", meterValue);
        // HKUnit *caffeintUnit = [HKUnit unit]
        dispatch_async(dispatch_get_main_queue(), ^{
            _txtCaffeine.text = [NSNumberFormatter localizedStringFromNumber:@(meterValue) numberStyle:NSNumberFormatterNoStyle];;
        });
        
    }
                                                                
    }];
    
}

- (void)updateUsersHeightLabel {
    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitInch;
    NSString *heightUnitString = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    NSString *localizedHeightUnitDescriptionFormat = NSLocalizedString(@"Height (%@)", nil);
    
    _txtCalcium.text = [NSString stringWithFormat:localizedHeightUnitDescriptionFormat, heightUnitString];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [[HKHealthKitManager sharedManager] mostRecentQuantitySampleOfType: heightType
                                                             predicate: nil
                                                            completion: ^(HKQuantity *mostRecentQuantity, NSError *error) {
   if (!mostRecentQuantity) {
       NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
       
       dispatch_async(dispatch_get_main_queue(), ^{
           _txtCalcium.text = NSLocalizedString(@"Not available", nil);
       });
   }
   else {
       // Determine the height in the required unit.
       HKUnit *heightUnit = [HKUnit inchUnit];
       double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
       
       // Update the user interface.
       dispatch_async(dispatch_get_main_queue(), ^{
           _txtCalcium.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
       });
   }
   }];
}

- (IBAction)SaveToHealthKit:(id)sender {
}


@end
