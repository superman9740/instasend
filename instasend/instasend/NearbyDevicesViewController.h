//
//  NearbyDevicesViewController.h
//  instasend
//
//  Created by sdickson on 3/19/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbyDevicesTableViewCell.h"
#import "NearbyDevicesDeviceView.h"

@import QuartzCore;

@interface NearbyDevicesViewController : UIViewController
{
    
    
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;



-(IBAction)refreshViews:(id)sender;

-(IBAction)showDeviceActionSheet:(id)sender;


@end
