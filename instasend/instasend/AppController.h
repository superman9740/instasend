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
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>




#define kRefreshDevicesView @"refreshDevicesView"
#define kRefreshActivityView @"refreshActivityView"


@interface AppController : NSObject
{

    dispatch_queue_t listenForAccouncementRequestsQueue;
    dispatch_queue_t listenForAccouncementResponsesQueue;
}

@property (nonatomic, strong) NSMutableArray*  devices;
@property (nonatomic, strong) NSMutableArray*  activityEntries;

@property (nonatomic, strong) NSMutableSet*  trustedDevices;

@property (nonatomic, strong) NSString* trustToken;

@property (nonatomic, strong) NSString* trustTokenWithPendingInvite;

@property (nonatomic, strong) NSMutableArray* inviteHandlerArray;

@property (nonatomic, strong) Device* selectedDevice;

@property (nonatomic, strong) NSData* dataToSend;
@property (nonatomic, strong) NSMutableData* incomingData;




-(void)initialize;

+ (id)sharedInstance;


-(void)sendInvite:(Device*)device trusted:(BOOL)trusted;

-(void)acceptInvitation:(NSString*)trustToken;

-(void)sendPhoto:(UIImage*)photo;

#pragma mark socket methods
-(void)listenForAnnouncementRequests;
-(void)listenForAnnouncementResponses;



-(void)sendBroadcastForPeers;
-(void)sendAnnouncementResponse;

@end
