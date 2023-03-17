//
//  DataTableViewCell.h
//  DeviceTracker
//
//  Created by Dhara on 27/01/16.
//  Copyright © 2016 Net4Nuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBmanager.h"
@interface DataTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbllocation;
@property (strong, nonatomic) IBOutlet UILabel *lbltime;
@property (strong, nonatomic) IBOutlet UILabel *lblspeed;
@property (strong, nonatomic) IBOutlet UILabel *lbltype;

@end
