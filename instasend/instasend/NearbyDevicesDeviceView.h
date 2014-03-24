//
//  NearbyDevicesDeviceView.h
//  instasend
//
//  Created by sdickson on 3/24/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@import MultipeerConnectivity;


@interface NearbyDevicesDeviceView : UIView<UIActionSheetDelegate>

{
    
    
}

@property (nonatomic, strong) Device* device;

-(IBAction)showDeviceActionSheet:(id)sender;


@end
