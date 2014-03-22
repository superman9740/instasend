//
//  NearbyDevicesTableViewCell.h
//  instasend
//
//  Created by Shane Dickson on 3/22/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppController.h"
#import "Device.h"

@interface NearbyDevicesTableViewCell : UITableViewCell
{
    
    
}

@property (nonatomic, strong) IBOutlet UILabel* deviceGroup;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;





@end
