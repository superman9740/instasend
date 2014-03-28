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
        _activityEntries = [[NSMutableArray alloc] initWithCapacity:10];
        
        _ipAddress = [self getIPAddress];
        
        //_trustedDevices = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _trustToken = [defaults objectForKey:@"trustToken"];
        _trustedDevices = [NSMutableSet setWithArray:[defaults objectForKey:@"trustedDevices"]];
        _inviteHandlerArray = [[NSMutableArray alloc] initWithCapacity:1];
        
        listenForAccouncementRequestsQueue =  dispatch_queue_create("com.instasend.announcement.requests",NULL);
        listenForAccouncementResponsesQueue =  dispatch_queue_create("com.instasend.announcement.responses",NULL);
        photoReceiverQueue = dispatch_queue_create("com.instasend.photoreceiver",NULL);
        
        [self listenForAnnouncementRequests];
        [self listenForAnnouncementResponses];
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
        
        [self sendAnnouncementResponse];
        
        [self sendBroacastForPeers:self];
    
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                  target:self
                                                selector:@selector(sendBroacastForPeers:)
                                                userInfo:nil
                                                 repeats:YES];
      
        
    }
    
    return self;
    
}
-(void)initialize
{
    
    
 //   NSDictionary* discoveryInfo = [NSDictionary dictionaryWithObjectsAndKeys:deviceName,@"deviceName", model, @"deviceModel",_trustToken, @"trustToken", nil];
    
    
   
    
}
-(void)listenForAnnouncementRequests
{
 
    dispatch_async(listenForAccouncementRequestsQueue,^{
        
        struct sockaddr_in myaddr;      /* our address */
        struct sockaddr_in remaddr;     /* remote address */
        socklen_t addrlen = sizeof(remaddr);            /* length of addresses */
        int recvlen;                    /* # bytes received */
        int fd;                         /* our socket */
        unsigned char buf[1024];     /* receive buffer */
        
        /* create a UDP socket */
        
        if ((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
            perror("cannot create socket\n");
            return ;
        }
        
        /* bind the socket to any valid IP address and a specific port */
        
        memset((char *)&myaddr, 0, sizeof(myaddr));
        myaddr.sin_family = AF_INET;
        myaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        myaddr.sin_port = htons(1900);
        
        if (bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
            perror("bind failed");
            return ;
        }
        
        /* now loop, receiving data and printing what we received */
        for (;;) {
            printf("waiting on port %d\n", 1900);
            recvlen = recvfrom(fd, buf, 1024, 0, (struct sockaddr *)&remaddr, &addrlen);
            char *ip = inet_ntoa(remaddr.sin_addr);
            printf("received %d bytes from remote IP address:  %s\n", recvlen,ip);
            if (recvlen > 0) {
                buf[recvlen] = 0;
                printf("received message: \"%s\"\n", buf);
                [self sendAnnouncementResponse];
                
                
            }
        }
        
        
        
    });
    
    
    
}

-(void)listenForAnnouncementResponses
{
    
    dispatch_async(listenForAccouncementResponsesQueue,^{
        
        struct sockaddr_in myaddr;      /* our address */
        struct sockaddr_in remaddr;     /* remote address */
        socklen_t addrlen = sizeof(remaddr);            /* length of addresses */
        int recvlen;                    /* # bytes received */
        int fd;                         /* our socket */
        unsigned char buf[1024];     /* receive buffer */
        
        /* create a UDP socket */
        
        if ((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
            perror("cannot create socket\n");
            return ;
        }
        
        /* bind the socket to any valid IP address and a specific port */
        
        memset((char *)&myaddr, 0, sizeof(myaddr));
        myaddr.sin_family = AF_INET;
        myaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        myaddr.sin_port = htons(1901);
        
        if (bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
            perror("bind failed");
            return ;
        }
        
        /* now loop, receiving data and printing what we received */
        for (;;) {
            printf("waiting on port %d\n", 1901);
            recvlen = recvfrom(fd, buf, 1024, 0, (struct sockaddr *)&remaddr, &addrlen);
            char* ip = inet_ntoa(remaddr.sin_addr);
            
            printf("received %d announcement response from remote IP address:  %s\n", recvlen,ip);
            if (recvlen > 0) {
                buf[recvlen] = 0;
                printf("received message: \"%s\"\n", buf);
                
                
  /*
                for(int counter = 0;counter < _devices.count;counter++)
                {
                    Device* tempObj = _devices[counter];
                    
               //     if(tempObj.peerID == peerID)
               //     {
                        return;
                        
                    }
                    
                }
    */
                NSString* str = [[NSString alloc] initWithBytes:buf length:sizeof(buf) encoding:NSASCIIStringEncoding];
                NSArray* components = [str componentsSeparatedByString:@"|"];
                
                
                
                
                
                NSString* deviceName = components[0];
                NSString* deviceModel = components[1];
                NSString* deviceTrustKey = components[2];
                NSString* ipAddr = components[3];
                NSArray* ipStringParts = [ipAddr componentsSeparatedByString:@"."];
                NSArray* currentIPStringParts = [_ipAddress componentsSeparatedByString:@"."];
                
                int val1 = [ipStringParts[0] intValue];
                int val2= [ipStringParts[1] intValue];
                int val3 = [ipStringParts[2] intValue];
                int val4 = [ipStringParts[3] intValue];
                
                
                int val5 = [currentIPStringParts[0] intValue];
                int val6= [currentIPStringParts[1] intValue];
                int val7 = [currentIPStringParts[2] intValue];
                int val8 = [currentIPStringParts[3] intValue];
                
                if(val1 == val5 && val2 == val6 && val3 == val7 && val4 == val8)
                {
                    continue;
                }
                else
                {
                    NSLog(@"A peer was found:  %@, of model type:  %@, with trustKey:  %@, and IP address:  %@", deviceName,deviceModel,deviceTrustKey, ipAddr);
                    
                    
                    Device* newDevice = [[Device alloc] init];
                    newDevice.deviceName = deviceName;
                    newDevice.trustKey = deviceTrustKey;
                    newDevice.ipAddress = ipAddr;
                    
                    if(_devices.count == 0)
                    {
                        [_devices addObject:newDevice];
                        
                    }
                    for(Device* dev in _devices)
                    {
                        if([dev.trustKey isEqualToString:deviceTrustKey])
                        {
                            
                            
                            
                        }
                        else
                        {
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
                            
                           
                            
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if(!_actionSheetIsBeingShown)
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDevicesView object:nil];
                        }
                        
                        
                    });
                    
                    
                    
                    
                }
            
            }
        }
        
      
        
        });
    
    
   
    
    
    
    
}

-(void)sendAnnouncementResponse
{
    // Open a socket
    int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sd<=0) {
        
    }
    
    // Set socket options
    // Enable broadcast
    int broadcastEnable=1;
    int ret=setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        close(sd);
        
    }
    
    // Since we don't call bind() here, the system decides on the port for us, which is what we want.
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr; // Make an endpoint
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(1901); // Set port 1901
    
    // Send the broadcast request, ie "Any upnp devices out there?"
    NSString* deviceName = [[UIDevice currentDevice] name];
    NSString* model = [[UIDevice currentDevice] model];
    NSString* responseStr = [NSString stringWithFormat:@"%@|%@|%@|%@",deviceName,model,_trustToken,_ipAddress];
    
    const char *response = [responseStr UTF8String];
    int totalBytesToSend = strlen(response);
    
    ret = sendto(sd, response, strlen(response), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    
    if (ret<0) {
        printf("Socket Sendto error %d : %s\n", errno, strerror(errno));
        close(sd);
        
    }
    
    
    close(sd);

    
}
-(IBAction)sendBroacastForPeers:(id)sender
{
    if(_actionSheetIsBeingShown)
        return;
    
    

    
    // Open a socket
    int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sd<=0) {
        return ;
    }
    
    // Set socket options
    // Enable broadcast
    int broadcastEnable=1;
    int ret=setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        close(sd);
        return ;
    }
    
    // Since we don't call bind() here, the system decides on the port for us, which is what we want.
    
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr; // Make an endpoint
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(1900); // Set port 1900
    
    // Send the broadcast request, ie "Any upnp devices out there?"
    char *request = "requestForBroadcast";
    ret = sendto(sd, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    if (ret<0) {
        close(sd);
        return ;
    }
    [_devices removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshDevicesView object:nil];

    
}


#pragma mark receive photo

-(void)setUpPhotoReceiver
{
    
    
    dispatch_async(photoReceiverQueue,^{
    
        
    struct sockaddr_in stSockAddr;
    int SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if(-1 == SocketFD)
    {
        perror("can not create socket");
        exit(EXIT_FAILURE);
    }
    
    memset(&stSockAddr, 0, sizeof(stSockAddr));
    
    stSockAddr.sin_family = AF_INET;
    stSockAddr.sin_port = htons(1903);
    stSockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    if(-1 == bind(SocketFD,(struct sockaddr *)&stSockAddr, sizeof(stSockAddr)))
    {
        perror("error bind failed");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }
    
    if(-1 == listen(SocketFD, 10))
    {
        perror("error listen failed");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }
    
    for(;;)
    {
        int ConnectFD = accept(SocketFD, NULL, NULL);
        
        if(0 > ConnectFD)
        {
            perror("error accept failed");
            close(SocketFD);
            exit(EXIT_FAILURE);
        }
        
        /* perform read write operations ...
         read(ConnectFD,buff,size)*/
        
        if (-1 == shutdown(ConnectFD, SHUT_RDWR))
        {
            perror("can not shutdown socket");
            close(ConnectFD);
            close(SocketFD);
           
        }
        close(ConnectFD);
    }
    
    close(SocketFD);
    
        
    });
    
                   
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
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
    
    
    
    struct sockaddr_in stSockAddr;
    int Res;
    int SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (-1 == SocketFD)
    {
        perror("cannot create socket");
        exit(EXIT_FAILURE);
    }
    
    memset(&stSockAddr, 0, sizeof(stSockAddr));
    
    stSockAddr.sin_family = AF_INET;
    stSockAddr.sin_port = htons(1903);
    Res = inet_pton(AF_INET, selectedDevice.ipAddress.UTF8String, &stSockAddr.sin_addr);
    
    if (0 > Res)
    {
        perror("error: first parameter is not a valid address family");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }
    else if (0 == Res)
    {
        perror("char string (second parameter does not contain valid ipaddress)");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }
    
    if (-1 == connect(SocketFD, (struct sockaddr *)&stSockAddr, sizeof(stSockAddr)))
    {
        perror("connect failed");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }
    
    long totalBytesToSend = [data length];
    long bytesWritten = 0;
    long totalBytesWritten = 0;
    uint8_t buffer[1025];
    uint8_t *readBytes = (uint8_t *)[data bytes];
    
    while(totalBytesWritten < totalBytesToSend)
    {
        bzero(buffer, 1024);
        
        memcpy(buffer,readBytes,1024);
        try {
       
            bytesWritten = send(SocketFD, buffer, 1024, 0);
            
        } catch (NSException* e)
        {
            int x = 5;
            
        }
        
        totalBytesWritten += bytesWritten;
        
        
    }
    /* perform read write operations ... */
    
    (void) shutdown(SocketFD, SHUT_RDWR);
    
    close(SocketFD);
    
    //[_session sendResourceAtURL:fileURL withName:@"photo.png" toPeer:_selectedDevice.peerID withCompletionHandler:nil];
    
    
    
    
    
    
    
}


@end
