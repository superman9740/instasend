//
//  AppController.m
//  sublime
//
//  Created by Shane Dickson on 3/9/14.
//
//

#import "AppController.h"
#import "Device.h"

static  AppController* sharedInstance = nil;


@implementation AppController


+ (AppController *)sharedInstance {
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
        
        
        
    }
    
    return sharedInstance;
}

-(id)init
{
    
    self = [super init];
    if(self)
    {
        _devices = [[NSMutableArray alloc] initWithCapacity:10];
        Device* newDevice = [[Device alloc] init];
        newDevice.deviceName = @"Test1";
        [_devices addObject:newDevice];
        
        
        
        
    }
    
    return self;
    
}


@end
