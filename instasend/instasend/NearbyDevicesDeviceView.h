//
//  NearbyDevicesDeviceView.h
//  instasend
//
//  Created by sdickson on 3/24/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "NearbyDevicesViewController.h"

@import MultipeerConnectivity;


@interface NearbyDevicesDeviceView : UIView<UIActionSheetDelegate>
{
  
    
}

@property (nonatomic, strong) Device* device;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong)   UIActionSheet* actionSheet;

-(IBAction)showDeviceActionSheet:(id)sender;
-(void)cancelActionSheet;


@end
