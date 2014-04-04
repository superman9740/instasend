//
//  AppController.h
//  instasend
//
//  Created by Shane Dickson on 3/9/14.
//
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "Activity.h"


//#include <iostream>




#define kRefreshDevicesView @"refreshDevicesView"
#define kRefreshActivityView @"refreshActivityView"


@interface AppController : NSObject
{

    CFSocketRef _ipv4socket;
    
    
       
}


@property (nonatomic, strong, readwrite) NSNetService*     netService;
@property (nonatomic, strong, readonly ) NSMutableSet*     connections;



@property (nonatomic, strong) NSMutableArray*  devices;
@property (nonatomic, strong) NSMutableArray*  activityEntries;

@property (nonatomic, strong) NSMutableSet*  trustedDevices;

@property (nonatomic, strong) NSString* trustToken;

@property (nonatomic, strong) NSString* trustTokenWithPendingInvite;

@property (nonatomic, strong) NSMutableArray* inviteHandlerArray;

@property (nonatomic, strong) Device* selectedDevice;

@property (nonatomic, strong) NSData* dataToSend;
@property (nonatomic, strong) NSMutableData* incomingData;


@property (nonatomic, strong) NSString* ipAddress;


@property (nonatomic, assign) BOOL actionSheetIsBeingShown;

-(void)initialize;

+ (id)sharedInstance;


-(void)sendInvite:(Device*)device trusted:(BOOL)trusted;

-(void)acceptInvitation:(NSString*)trustToken;

-(void)sendPhoto:(UIImage*)photo;

#pragma mark socket methods
-(void)setUpPhotoReceiver;

- (NSString *)getIPAddress;


@end
