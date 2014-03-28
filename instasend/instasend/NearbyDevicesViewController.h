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
@import CoreImage;
@import CoreMedia;
@import ImageIO;
@import QuartzCore;
@import MobileCoreServices;

@interface NearbyDevicesViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) Device* device;
@property(nonatomic, strong) UIImagePickerController* pickerController;




-(IBAction)refreshViews:(id)sender;

-(IBAction)showDeviceActionSheet:(id)sender;

-(IBAction)selectPhotos:(id)sender;



@end
