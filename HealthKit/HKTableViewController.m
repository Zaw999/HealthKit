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
    _txtCaffeine.delegate = self;
    
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
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear: animated];
    
    [self updateCaffeineType];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    textField.text = nil;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
        HKUnit *caffeintUnit = [HKUnit gramUnit];
        double caffeine = [mostRecentQuantity doubleValueForUnit: caffeintUnit];
        double mgValue = caffeine * 1000;
        NSLog(@"CaffeineType : %f", mgValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            _txtCaffeine.text = [NSNumberFormatter localizedStringFromNumber:@(mgValue) numberStyle:NSNumberFormatterNoStyle];;
        });
        
    }
                                                                
    }];
    
}

- (IBAction)SaveToHealthKit:(id)sender {
    
    NSLog(@"SaveToHealthKit");
    
    [[HKHealthKitManager sharedManager] saveNutrition: [_txtCaffeine.text integerValue]
                                       withCompletion: ^(BOOL result){
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
