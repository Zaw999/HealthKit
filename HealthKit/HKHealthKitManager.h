//
//  HKHealthKitManager.h
//  HealthKit
//
//  Created by Zaw Ye Naing on 2018/02/03.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface HKHealthKitManager : NSObject

+ (HKHealthKitManager *)sharedManager;

- (NSSet *)dataTypesToWrite;
- (NSSet *)dataTypesToRead;
- (void)requestAuthorization;

- (void)mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType
predicate:(NSPredicate *)predicate
completion:(void (^)(HKQuantity *, NSError *))completion;

- (NSDate *)readBirthDate;
- (void)saveHKSample: (float)weight
        heightSample: (float)height
      withCompletion: (void (^)(BOOL success))completionHandler;

-(void)saveNutrition: (float)caffeine
             calcium: (float)calcium
      carbonHydrates: (float)carbonHydrates
            chloride: (float)chloride
            chromium: (float)chromium
      withCompletion: (void (^)(BOOL result))completionHandler;

@end
