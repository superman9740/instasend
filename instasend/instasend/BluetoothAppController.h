//
//  BluetoothAppController.h
//  instasend
//
//  Created by sdickson on 4/4/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

#define DEVICE_INFO_SERVICE_UUID @"71DA3FD1-7E10-41C1-B16F-4430B506CDE7"



@interface BluetoothAppController : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    
    
}

@property (nonatomic, strong) CBCentralManager* centralManager;
@property (nonatomic, strong) CBPeripheral* clientPeripheral;


+ (id)sharedInstance;



@end
