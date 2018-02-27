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
{
    NSMutableArray *healthKitArray;
}


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
    
    healthKitArray = [NSMutableArray array];
    
    _txtCaffeine.delegate        = self;
    _txtCalcium.delegate         = self;
    _txtCarbonHydrates.delegate  = self;
    _txtChloride.delegate        = self;
    _txtChromium.delegate        = self;
    
    NSDictionary *caffeineType = @{@"HKQuantityType": [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine], @"TextField": _txtCaffeine};
    
    NSDictionary *calciumType = @{@"HKQuantityType": [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCalcium], @"TextField": _txtCalcium};
    
    NSDictionary *carbohydratesType = @{@"HKQuantityType": [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCarbohydrates], @"TextField": _txtCarbonHydrates};
    
    NSDictionary *chlorideType = @{@"HKQuantityType": [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChloride], @"TextField": _txtChloride};
    
    NSDictionary *chromiumType = @{@"HKQuantityType": [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChromium], @"TextField": _txtChromium};

    healthKitArray = [@[caffeineType, calciumType, carbohydratesType, chlorideType, chromiumType] mutableCopy];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    [_txtCaffeine resignFirstResponder];
}

- (IBAction)requestAuthorization:(UISwitch *)sender {
    
    if(sender.isOn) {
        [[HKHealthKitManager sharedManager] requestAuthorization];
    } else {
        //
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear: animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < [healthKitArray count]; i++) {
            [self updateHKQuantityType: [healthKitArray objectAtIndex:i][@"HKQuantityType"] showResult: [healthKitArray objectAtIndex:i][@"TextField"]];
        }
    });
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)updateHKQuantityType:(HKQuantityType *)quantityType
                  showResult:(UITextField *)showResult {
    
    [[HKHealthKitManager sharedManager] mostRecentQuantitySampleOfType: quantityType
                                                             predicate: nil
                                                            completion: ^(HKQuantity *mostRecentQuantity, NSError *error) {
                                                                
    if (!mostRecentQuantity) {
        dispatch_async(dispatch_get_main_queue(), ^{
            showResult.text = @"-";
        });
        
    } else {
        double caffeine = 0.0;
        
        if ([quantityType.identifier isEqualToString: HKQuantityTypeIdentifierDietaryCaffeine] ||
            [quantityType.identifier isEqualToString: HKQuantityTypeIdentifierDietaryCalcium]  ||
            [quantityType.identifier isEqualToString: HKQuantityTypeIdentifierDietaryChloride]) {
            caffeine = [mostRecentQuantity doubleValueForUnit: [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli]];
        }
        if ([quantityType.identifier isEqualToString: HKQuantityTypeIdentifierDietaryCarbohydrates]) {
            caffeine = [mostRecentQuantity doubleValueForUnit: [HKUnit gramUnit]];
        }
        if ([quantityType.identifier isEqualToString: HKQuantityTypeIdentifierDietaryChromium]) {
            caffeine = [mostRecentQuantity doubleValueForUnit: [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMicro]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            showResult.text = [NSNumberFormatter localizedStringFromNumber:@(caffeine) numberStyle:NSNumberFormatterNoStyle];;
        });
        
    }
    }];
}

- (IBAction)SaveToHealthKit:(id)sender {
    
    NSLog(@"SaveToHealthKit");
    
    [[HKHealthKitManager sharedManager] saveNutrition: [_txtCaffeine.text integerValue]
                                              calcium: [_txtCalcium.text integerValue]
                                       carbonHydrates: [_txtCarbonHydrates.text integerValue]
                                             chloride: [_txtChloride.text integerValue]
                                             chromium: [_txtChromium.text integerValue]
                                       withCompletion: ^(BOOL result){
        if (result) {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"Saved to HealthKit!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)updateUsersHeightLabel {
    /*
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
     */
}




@end
