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
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        [_devices addObject:newDevice];
        
        
        //Multipeer startup - advertise and discover
        NSString* deviceName = [[UIDevice currentDevice] name];
        NSString* model = [[UIDevice currentDevice] model];
        
        _peerID = [[MCPeerID alloc] initWithDisplayName:deviceName];
        _session = [[MCSession alloc] initWithPeer:_peerID];
        _session.delegate = self;
        NSDictionary* discoveryInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceName,@"deviceName", model, @"deviceModel", nil];
        
        
        _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:discoveryInfo serviceType:@"instasend"];
        
        
        [_serviceAdvertiser startAdvertisingPeer];
        _serviceAdvertiser.delegate = self;
        
        
        //Browse to see who is available
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"instasend"];
        _browser.delegate = self;
        
        [_browser startBrowsingForPeers];
        
        
    }
    
    return self;
    
}


- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"error:  %@", error.localizedDescription);
    
    
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    
    invitationHandler(YES, _session);
    
    
}


- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"didReceiveData %@ from %@", receivedMessage, peerID.displayName);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    
    NSString* deviceName = info[@"deviceName"];
    NSLog(@"A peer was found:  %@", deviceName);
    
    //Now invite this peer to this session
   // [_browser invitePeer:peerID toSession:_session withContext:nil timeout:30.0];
    
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"A peer was lost:  %@", peerID);
    
    
}
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state)
    {
        case MCSessionStateNotConnected:
        {
            NSLog(@"Peer %@ has disconnected.", peerID);
            
            break;
            
        }
        case MCSessionStateConnected:
        {
            NSError* error = nil;
            
            NSLog(@"Peer %@ has connected.", peerID);
            NSString* str = @"Testing";
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSArray* peersArray = [NSArray arrayWithObject:peerID];
            [_session sendData:data toPeers:peersArray withMode:MCSessionSendDataReliable error:&error];
            
            break;
            
        }
            
        case MCSessionStateConnecting:
        {
            NSLog(@"Peer %@ is connecting.", peerID);
            
            break;
            
        }
        default:
            break;
    }
    
    
}


@end
