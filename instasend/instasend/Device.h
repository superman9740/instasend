//
//  Device.h
//  instasend
//
//  Created by sdickson on 3/19/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject
{
    
    
}

@property (nonatomic, strong) NSString* deviceName;
@property (nonatomic, strong) NSString* ipAddress;

@property (nonatomic, strong) NSString* trustKey;

@property (nonatomic, assign) BOOL isTrusted;

@end
