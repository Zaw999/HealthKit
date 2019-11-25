//
//  StepCountViewController.h
//  HealthKit
//
//  Created by zawyenaing on 2018/07/31.
//  Copyright © 2018 Zaw Ye Naing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StepCountViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableView;

@end
