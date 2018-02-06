//
//  HKHealthKitManager.h
//  HealthKit
//
//  Created by Zaw Ye Naing on 2018/02/03.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKHealthKitManager : NSObject

+ (HKHealthKitManager *)sharedManager;

- (void)requestAuthorization;

- (NSDate *)readBirthDate;
- (void)saveHKSample: (float)weight
        heightSample: (float)height
      withCompletion: (void (^)(BOOL success))completionHandler;

@end
