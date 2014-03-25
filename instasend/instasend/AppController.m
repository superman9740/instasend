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
        //_trustedDevices = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _trustToken = [defaults objectForKey:@"trustToken"];
        _trustedDevices = [NSMutableSet setWithArray:[defaults objectForKey:@"trustedDevices"]];
        _inviteHandlerArray = [[NSMutableArray alloc] initWithCapacity:1];
        
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
        
        //Multipeer startup - advertise and discover
        
    }
    
    return self;
    
}
-(void)initialize
{
    
    NSString* deviceName = [[UIDevice currentDevice] name];
    NSString* model = [[UIDevice currentDevice] model];
    
    _peerID = [[MCPeerID alloc] initWithDisplayName:deviceName];
    _session = [[MCSession alloc] initWithPeer:_peerID];
    _session.delegate = self;
    NSDictionary* discoveryInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceName,@"deviceName", model, @"deviceModel",_trustToken, @"trustToken", nil];
    
    
    _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:discoveryInfo serviceType:@"instasend"];
    
    
    [_serviceAdvertiser startAdvertisingPeer];
    _serviceAdvertiser.delegate = self;
    
    
    //Browse to see who is available
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:@"instasend"];
    _browser.delegate = self;
    
    [_browser startBrowsingForPeers];
    

    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"error:  %@", error.localizedDescription);
    
    
}
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

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"didReceiveData %@ from %@", receivedMessage, peerID.displayName);
}

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
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasSpaceAvailable:
        {
            NSOutputStream* outputStream = (NSOutputStream*)stream;
            uint32_t length = (uint32_t)htonl([_dataToSend length]);
            [outputStream write:(uint8_t *)&length maxLength:4];
            //[outputStream write:[_dataToSend bytes] maxLength:length];
            break;
        }
        case NSStreamEventOpenCompleted:
        {
            
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            NSInputStream* inputStream = (NSInputStream*)stream;
            if(!_incomingData) {
                _incomingData = [NSMutableData data];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:4];
            if(len)
            {
                [_incomingData appendBytes:(const void *)buf length:4];
                // bytesRead is an instance variable of type NSNumber.
               // [bytesRead setIntValue:[bytesRead intValue]+len];
            } else {
                NSLog(@"no buffer!");
            }

            
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            
            break;
        }
    }
    
}
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
    
    
    [_browser invitePeer:peerID toSession:_session withContext:context timeout:30.0];
    
    
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

    
    invitationHandler(YES, _session);
    
    
}
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    int x = 5;
    
    
    
}
-(void)sendPhoto:(UIImage*)photo
{
    MCPeerID* selectedPeer = _selectedDevice.peerID;
    NSArray* peers = [NSArray arrayWithObject:selectedPeer];
    NSError* error = nil;
    
    
    NSData *data = UIImagePNGRepresentation(photo);
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *tmpFile = [tmpDirectory stringByAppendingPathComponent:@"photo.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:tmpFile contents:data attributes:nil];
    NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:tmpFile];
    
    
    [_session sendResourceAtURL:fileURL withName:@"photo.png" toPeer:_selectedDevice.peerID withCompletionHandler:nil];
    
    
    
    
    
    
    
}

@end
