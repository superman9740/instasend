//
//  AppController.m
//  sublime
//
//  Created by Shane Dickson on 3/9/14.
//
//

#import "AppController.h"
#import "Device.h"


#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>


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
          _connections = [[NSMutableSet alloc] init];
        
        _devices = [[NSMutableArray alloc] initWithCapacity:10];
        _activityEntries = [[NSMutableArray alloc] initWithCapacity:10];
        
      
        
        //_trustedDevices = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _trustToken = [defaults objectForKey:@"trustToken"];
        _trustedDevices = [NSMutableSet setWithArray:[defaults objectForKey:@"trustedDevices"]];
        _inviteHandlerArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        
        [self setUpPhotoReceiver];
        
        if(_trustToken == nil)
        {
            _trustToken =  [[NSProcessInfo processInfo] globallyUniqueString];
            [defaults setObject:_trustToken forKey:@"trustToken"];
            [defaults synchronize];
            
            
        }
   
        if(_trustedDevices == nil)
        {
            _trustedDevices = [[NSMutableSet alloc] initWithCapacity:10];
            [defaults setObject:_trustedDevices.allObjects forKey:@"trustedDevices"];
            [defaults synchronize];
            
        }
        
        
        
        
    }
    
    CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
    _ipv4socket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack, &EchoServerAcceptCallBack, &socketCtxt);
    
    
    static const int yes = 1;
    (void) setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
    
    // Set up the IPv4 listening socket; port is 0, which will cause the kernel to choose a port for us.
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(1900);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)])) {
       // [self stop];
        return NO;
    }
    
    // Now that the IPv4 binding was successful, we get the port number
    // -- we will need it for the IPv6 listening socket and for the NSNetService.
   
    // Set up the run loop sources for the sockets.
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
    CFRelease(source4);
    
    
    self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_cocoaecho._tcp." name:@"" port:(int) 1900];
    [self.netService publishWithOptions:0];
    
    
    
    return self;
    
}
static void EchoServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    assert(type == kCFSocketAcceptCallBack);
#pragma unused(type)
#pragma unused(address)
    
    AppController* server = (__bridge AppController* )info;
  
#pragma unused(socket)
    
    // For an accept callback, the data parameter is a pointer to a CFSocketNativeHandle.
    [server acceptConnection:*(CFSocketNativeHandle *)data];
}


- (void)acceptConnection:(CFSocketNativeHandle)nativeSocketHandle
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
 /*
        EchoConnection * connection = [[EchoConnection alloc] initWithInputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)writeStream];
        [self.connections addObject:connection];
        [connection open];
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(echoConnectionDidCloseNotification:) name:EchoConnectionDidCloseNotification object:connection];
        NSLog(@"Added connection.");
    } else {
        // On any failure, we need to destroy the CFSocketNativeHandle
        // since we are not going to use it any more.
        (void) close(nativeSocketHandle);
    }
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
*/
    }
    
  
}

-(void)initialize
{
    
    
 //   NSDictionary* discoveryInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceName,@"deviceName", model, @"deviceModel",_trustToken, @"trustToken", nil];
    
    
   
    
}

#pragma mark receive photo

-(void)setUpPhotoReceiver
{
    
    
  
}


/*
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"didReceiveInvitationFromPeer %@", peerID.displayName);
    NSString* incomingTrustToken = [[NSString alloc] initWithData:context encoding:NSUTF8StringEncoding];
    
    _trustTokenWithPendingInvite = incomingTrustToken;
    [_inviteHandlerArray addObject:invitationHandler];
    
    
    for(int counter = 0;counter < _trustedDevices.count;counter++)
    {
        
        NSString* trustedToken =  [_trustedDevices allObjects][counter];
    
        if([trustedToken isEqualToString:incomingTrustToken])
        {
            //Set up a session behind the scenes
            [self acceptInvitation:trustedToken];
            return;
        }
        else
        {
            UIAlertView* inviteView = [[UIAlertView alloc] initWithTitle:@"Incoming Invite" message:[NSString stringWithFormat:@"%@ has sent you an invite to become a trusted friend.  Do you accept?", peerID.displayName] delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:@"Decline", nil];
            
            [inviteView show];
            
            return;
        }
        
    }

    //No trusted tokens exist
    
    UIAlertView* inviteView = [[UIAlertView alloc] initWithTitle:@"Incoming Invite" message:[NSString stringWithFormat:@"%@ has sent you an invite to become a trusted friend.  Do you accept?", peerID.displayName] delegate:self cancelButtonTitle:@"Accept" otherButtonTitles:@"Decline", nil];
    
    [inviteView show];
    
    
    
}
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            //Accept invitation
            [self acceptInvitation:_trustTokenWithPendingInvite];
            break;
            
        }
            
        default:
            break;
    }
    
}

/*
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    for(int counter = 0;counter < _devices.count;counter++)
    {
        Device* tempObj = _devices[counter];
        
        if(tempObj.peerID == peerID)
        {
            return;
            
        }
        
    }
    
 
    
    
    NSString* deviceName = info[@"deviceName"];
    NSString* deviceModel = info[@"deviceModel"];
    NSString* deviceTrustKey = info[@"trustToken"];
    
    NSLog(@"A peer was found:  %@, of model type:  %@, with trustKey:  %@", deviceName,deviceModel,deviceTrustKey);
    Device* newDevice = [[Device alloc] init];
    newDevice.deviceName = deviceName;
    newDevice.peerID = peerID;
    newDevice.trustKey = deviceTrustKey;
    
    [_devices addObject:newDevice];
    
    //Check to see if the is a trusted device
    for(NSString* trustedToken in _trustedDevices)
    {
        if([trustedToken isEqualToString:deviceTrustKey])
        {
            //Set up a session behind the scenes
            _trustTokenWithPendingInvite = deviceTrustKey;
            
           // [self sendInvite:peerID trusted:YES];
            
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDevicesView object:nil];
    
    
    //Now invite this peer to this session
   // [_browser invitePeer:peerID toSession:_session withContext:nil timeout:30.0];
    
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"A peer was lost:  %@", peerID);
   
    for(int counter = 0;counter < _devices.count;counter++)
    {
        Device* tempObj = _devices[counter];
        
        if(tempObj.peerID == peerID)
        {
            [_devices removeObject:tempObj];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDevicesView object:nil];
            
        }
        
    }
    
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
          //  [_session sendData:data toPeers:peersArray withMode:MCSessionSendDataReliable error:&error];
            
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

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
    stream.delegate = self;
    
    
    [stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
   
    
}
 */
/*
-(void)sendInvite:(MCPeerID*)peerID trusted:(BOOL)trusted
{
    NSData* context = [_trustToken dataUsingEncoding:NSUTF8StringEncoding];
    if(!trusted)
    {
        [_trustedDevices addObject:_trustTokenWithPendingInvite];
    
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_trustedDevices.allObjects forKey:@"trustedDevices"];
        [defaults synchronize];
    }
    
    
//    [_browser invitePeer:peerID toSession:_session withContext:context timeout:30.0];
    
    
}
-(void)acceptInvitation:(NSString*)trustToken
{
    
    void (^invitationHandler)(BOOL, MCSession *) = [_inviteHandlerArray objectAtIndex:0];

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDevicesView object:nil];
    
    for(int counter = 0;counter < _trustedDevices.count;counter++)
    {
        NSString* token = [_trustedDevices allObjects][counter];
        if([trustToken isEqualToString:token])
        {
            break;
        }
        
        
    }
    [_trustedDevices addObject:trustToken];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_trustedDevices.allObjects forKey:@"trustedDevices"];
    [defaults synchronize];

    
  //  invitationHandler(YES, _session);
    
    
}
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    int x = 5;
    
    //Add an activity entry
    Activity* activity = [[Activity alloc] init];
    activity.activityType = @"Receiving";
    activity.deviceName = peerID.displayName;
    [_activityEntries addObject:activity];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshActivityView object:self userInfo:nil];
    
    
    
}
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
    
}
*/
 -(void)sendPhoto:(UIImage*)photo
{
    Device* selectedDevice = _selectedDevice;
    
    
    NSData *data = UIImagePNGRepresentation(photo);
    /*
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDirectory stringByAppendingPathComponent:@"photo.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:tmpFile contents:data attributes:nil];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:tmpFile];
    */
    
    //Add an activity entry
    Activity* activity = [[Activity alloc] init];
    activity.activityType = @"Sending";
    activity.deviceName = selectedDevice.deviceName;
    [_activityEntries addObject:activity];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshActivityView object:self userInfo:nil];
    
    
    
       
    
}


@end
