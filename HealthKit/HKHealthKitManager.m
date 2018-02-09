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

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    
    HKQuantityType *dobType = [HKObjectType quantityTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *caffeineType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
    HKQuantityType *calciumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCalcium];
    HKQuantityType *carboHydratesType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *chlorideType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChloride];
    HKQuantityType *chromiumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChromium];
    
    return [NSSet setWithObjects: dobType,heightType, caffeineType, calciumType, carboHydratesType, chlorideType, chromiumType, nil];
}

- (NSSet *)dataTypesToWrite {
    
    HKQuantityType *dobType = [HKObjectType quantityTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *caffeineType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
    HKQuantityType *calciumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCalcium];
    HKQuantityType *carboHydratesType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *chlorideType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChloride];
    HKQuantityType *chromiumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChromium];
    
    return [NSSet setWithObjects: caffeineType, heightType, calciumType, carboHydratesType, chlorideType, chromiumType, nil];
}

- (void)requestAuthorization {
    
//    if ([HKHealthStore isHealthDataAvailable] == NO) {
//        // If our device doesn't support HealthKit -> return.
//        // return;
//    }
    
    // NSSet *read = [self dataTypesToRead];
    NSArray *readTypes = @[[HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth], [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight], [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine]];
    
    [self.healthStore requestAuthorizationToShareTypes: [self dataTypesToWrite]
                                             readTypes: [NSSet setWithArray:readTypes]
                                            completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
            
            return;
        }
    }];
    
}

- (NSDateComponents *)readBirthDate {
    NSError *error;
    NSDateComponents *dateOfBirth = [self.healthStore dateOfBirthComponentsWithError: &error];   // Convenience method of HKHealthStore to get date of birth directly.
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the user interface based on the current user's health information.
        // [self updateCaffeineType];
    });
    
    
    return dateOfBirth;
}

- (void)updateCaffeineType {
    
    HKQuantityType *caffeineType = [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
    /*
    [self mostRecentQuantitySampleOfType: caffeineType
                               predicate: nil
                              completion: ^(HKQuantity *mostRecentQuantity, NSError *error) {
                                  
                                  if (!mostRecentQuantity) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                      });
                                  }
                              }];
    
    */
    
}

- (void)mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType
                             predicate:(NSPredicate *)predicate
                            completion:(void (^)(HKQuantity *, NSError *))completion {
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending: YES];
    
    NSString *endKey = HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDate = [NSSortDescriptor sortDescriptorWithKey:endKey ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:nil
                                                               limit:HKObjectQueryNoLimit
                                                     sortDescriptors:@[endDate]
                                                      resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
  if (!results) {
      if (completion) {
          completion(nil, error);
      }
      
      return;
  }
                                                          
  if (completion) {
      
      // If quantity isn't in the database, return nil in the completion block.
      HKQuantitySample *quantitySample = results.firstObject;
      HKQuantity *quantity = quantitySample.quantity;
      
      completion(quantity, error);
      
  }
  }];
    [self.healthStore executeQuery: query];
}


-(void)saveHKSample:(float)weight
             heightSample:(float)height withCompletion: (void (^)(BOOL result))completionHandler{
    
    // Each quantity consists of a value and a unit.
    HKUnit *kilogramUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:kilogramUnit doubleValue: weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    // For every sample, we need a sample type, quantity and a date.
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    double meterValue = height / 100;
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue: meterValue];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierHeight];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType: heightType quantity: heightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObjects: @[weightSample,heightSample] withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"result : %d", success);
        completionHandler(success);
        /*
        if (!success) {
            NSLog(@"Error while saving weight (%f) to Health Store: %@.", weight, error);
            completionHandler(success);
         }
         */
    }];
    
    
    
}

@end

