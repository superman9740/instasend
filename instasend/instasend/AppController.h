//
//  AppController.h
//  instasend
//
//  Created by Shane Dickson on 3/9/14.
//
//

#import <Foundation/Foundation.h>
#import "Device.h"

@import MultipeerConnectivity;

#define kRefreshDevicesView @"refreshDevicesView"

@interface AppController : NSObject<MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>

{
    
    
}

@property (nonatomic, strong) NSMutableArray*  devices;
@property (nonatomic, strong) NSMutableSet*  trustedDevices;

@property (nonatomic, strong) MCPeerID* peerID;
@property (nonatomic, strong) MCSession* session;
@property (nonatomic, strong) MCNearbyServiceAdvertiser* serviceAdvertiser;

@property (nonatomic, strong) MCNearbyServiceBrowser* browser;
@property (nonatomic, strong) MCBrowserViewController* browserViewController;
@property (nonatomic, strong) NSString* trustToken;

@property (nonatomic, strong) NSString* trustTokenWithPendingInvite;

@property (nonatomic, strong) NSMutableArray* inviteHandlerArray;



-(void)initialize;

+ (id)sharedInstance;


-(void)sendInvite:(MCPeerID*)device trusted:(BOOL)trusted;

-(void)acceptInvitation:(NSString*)trustToken;


@end
