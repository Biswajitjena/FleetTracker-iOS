//
//  DataViewController.h
//  DeviceTracker
//
//  Created by Dhara on 27/01/16.
//  Copyright © 2016 Net4Nuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBmanager.h"

@interface DataViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnDelete:(id)sender;

- (IBAction)btnReferesh:(id)sender;

- (IBAction)btnMap:(id)sender;
@end
