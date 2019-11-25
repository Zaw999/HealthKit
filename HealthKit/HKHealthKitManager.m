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
- (NSSet *)dataTypesToReadAndWrite {
    
    HKQuantityType *dobType = [HKObjectType quantityTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *caffeineType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
    HKQuantityType *calciumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCalcium];
    HKQuantityType *carboHydratesType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *chlorideType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChloride];
    HKQuantityType *chromiumType = [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChromium];
    HKQuantityType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];// 歩数
    
    return [NSSet setWithObjects: dobType,heightType, caffeineType, calciumType, carboHydratesType, chlorideType, chromiumType, stepCount, nil];
}

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
         return;
    }
    NSArray *readTypes = @[[HKObjectType characteristicTypeForIdentifier: HKCharacteristicTypeIdentifierDateOfBirth],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                           [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine],
                           [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCalcium],
                           [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCarbohydrates],
                           [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChloride],
                           [HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryChromium],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    [self.healthStore requestAuthorizationToShareTypes: [self dataTypesToReadAndWrite]
                                             readTypes: [NSSet setWithArray:readTypes]
                                            completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error : %@", error.localizedDescription);
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
    return dateOfBirth;
}

- (void)updateCaffeineType {
    
//    HKQuantityType *caffeineType = [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierDietaryCaffeine];
//    [self mostRecentQuantitySampleOfType: caffeineType
//                               predicate: nil
//                              completion: ^(HKQuantity *mostRecentQuantity, NSError *error) {
//
//                                  if (!mostRecentQuantity) {
//                                      dispatch_async(dispatch_get_main_queue(), ^{
//
//                                      });
//                                  }
//                              }];
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

- (void)mostRecentQuantitySampleOfTypeStepCount :(void (^)(NSMutableArray *))completion {

    NSMutableArray *stepCountData = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityTypeWalk = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *quantityTypeCaffeine = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityTypeWalk
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];
    
    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }
        
        NSDate *endDate = [NSDate date];
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                 value:-3
                                                toDate:endDate
                                               options:0];
          // If quantity isn't in the database, return nil in the completion block.
        NSLog(@"%@", results);
        // NSMutableArray *
        // Plot the daily step counts over the past 7 days
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {
                                       HKQuantity *quantity = result.sumQuantity;
                                       NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                       if (quantity) {
                                           NSDate *date = result.startDate;
                                           double stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           if (stepCountData > 0) {
                                               [dict setValue:date forKey:@"date"];
                                               [dict setValue:[NSString stringWithFormat:@"%d", @(stepCount).intValue] forKey:@"step_count"];
                                               [stepCountData addObject:dict];
                                           }
                                           NSLog(@"%@: %f", date, stepCount);
                                       }
                                   }];
        completion(stepCountData);
    };
    [self.healthStore executeQuery:query];
}

#pragma mark - Save To HealthKit.
-(void)saveHKSample:(float)weight
             heightSample:(float)height withCompletion: (void (^)(BOOL result))completionHandler {
    
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

-(void)saveNutrition: (float)caffeine
             calcium: (float)calcium
             carbonHydrates: (float)carbonHydrates
             chloride: (float)chloride
             chromium: (float)chromium
      withCompletion: (void (^)(BOOL result))completionHandler{
    
    NSDate *now = [NSDate date];
    
    HKUnit *caffeineUnit        = [HKUnit gramUnitWithMetricPrefix: HKMetricPrefixMilli];
    HKUnit *calciumUnit         = [HKUnit gramUnitWithMetricPrefix: HKMetricPrefixMilli];
    HKUnit *carbonHydratesUnit  = [HKUnit gramUnit];
    HKUnit *chlorideUnit        = [HKUnit gramUnitWithMetricPrefix: HKMetricPrefixMilli];
    HKUnit *chromiumUnit        = [HKUnit gramUnitWithMetricPrefix: HKMetricPrefixMicro];
    
    HKQuantity *caffeineQuantity        = [HKQuantity quantityWithUnit:caffeineUnit doubleValue:caffeine];
    HKQuantity *calciumQuantity         = [HKQuantity quantityWithUnit:calciumUnit doubleValue:calcium];
    HKQuantity *carbonHydratesQuantity  = [HKQuantity quantityWithUnit:carbonHydratesUnit doubleValue:carbonHydrates];
    HKQuantity *chlorideQuantity        = [HKQuantity quantityWithUnit:chlorideUnit doubleValue:chloride];
    HKQuantity *chromiumQuantity        = [HKQuantity quantityWithUnit:chromiumUnit doubleValue:chromium];
    
    HKQuantityType *caffeineType         = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    HKQuantityType *calciumType          = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalcium];
    HKQuantityType *carbonHydratesType   = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *chlorideType         = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
    HKQuantityType *chromiumType         = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChromium];
    
    
    HKQuantitySample *caffeineSample         = [HKQuantitySample quantitySampleWithType:caffeineType quantity:caffeineQuantity startDate:now endDate:now];
    HKQuantitySample *calciumSample          = [HKQuantitySample quantitySampleWithType:calciumType quantity:calciumQuantity startDate:now endDate:now];
    HKQuantitySample *carbonHydratesSample   = [HKQuantitySample quantitySampleWithType:carbonHydratesType quantity:carbonHydratesQuantity startDate:now endDate:now];
    HKQuantitySample *chlorideSample         = [HKQuantitySample quantitySampleWithType:chlorideType quantity:chlorideQuantity startDate:now endDate:now];
    HKQuantitySample *chromiumSample         = [HKQuantitySample quantitySampleWithType:chromiumType quantity:chromiumQuantity startDate:now endDate:now];
    
    [self.healthStore saveObjects: @[caffeineSample, calciumSample, carbonHydratesSample, chlorideSample, chromiumSample] withCompletion:^(BOOL success, NSError *error) {
        NSLog(@"result : %d", success);
        completionHandler(success);
    }];
}

@end

