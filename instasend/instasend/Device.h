//
//  Device.h
//  instasend
//
//  Created by sdickson on 3/19/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

@interface Device : NSObject
{
    
    
}

@property (nonatomic, strong) NSString* deviceName;
@property (nonatomic, strong) MCPeerID* peerID;

@end
