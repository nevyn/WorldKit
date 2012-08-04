//
//  ExampleMasterViewController.h
//  ExampleIOS
//
//  Created by Joachim Bengtsson on 2012-08-04.
//  Copyright (c) 2012 ThirdCog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExampleDetailViewController;

@interface ExampleMasterViewController : UITableViewController

@property (strong, nonatomic) ExampleDetailViewController *detailViewController;

@end
