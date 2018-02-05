//
//  HKHealthKitManager.m
//  HealthKit
//
//  Created by Zaw Ye Naing on 2018/02/03.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import "HKHealthKitManager.h"
#import <HealthKit/HealthKit.h>

@interface HKHealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end

@implementation HKHealthKitManager

+ (HKHealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static HKHealthKitManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[HKHealthKitManager alloc] init];
        instance.healthStore = [[HKHealthStore alloc] init];
    });
    return instance;
}

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        return;
    }
    /*
     NSArray *readTypes = @[[HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth], [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierBodyMass]];
     [self.healthStore requestAuthorizationToShareTypes:nil
     readTypes:[NSSet setWithArray:readTypes] completion:nil];
     */
    
    NSArray *readTypes = @[[HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth]];
    
    NSArray *writeTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]];
    
    /*
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:readTypes]
                                             readTypes:[NSSet setWithArray:writeTypes] completion:nil];
     */
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
                                             readTypes:[NSSet setWithArray:readTypes] completion:nil];
}

- (NSDateComponents *)readBirthDate {
    NSError *error;
    NSDateComponents *dateOfBirth = [self.healthStore dateOfBirthComponentsWithError: &error];   // Convenience method of HKHealthStore to get date of birth directly.
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
    }
    
    return dateOfBirth;
}

- (void)writeWeightSample:(float)weight {
    
    // Each quantity consists of a value and a unit.
    HKUnit *kilogramUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:kilogramUnit doubleValue: weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    // For every sample, we need a sample type, quantity and a date.
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObject: weightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error while saving weight (%f) to Health Store: %@.", weight, error);
        }
    }];
}


@end

