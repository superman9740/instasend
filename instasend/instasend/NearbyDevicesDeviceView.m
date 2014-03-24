//
//  NearbyDevicesDeviceView.m
//  instasend
//
//  Created by sdickson on 3/24/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import "NearbyDevicesDeviceView.h"
#import "AppController.h"

@implementation NearbyDevicesDeviceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(IBAction)showDeviceActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    
    
    [actionSheet addButtonWithTitle:@"Invite"];
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self];
    

    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex)
    {
        case 0:
        {
            //invite
            [[AppController sharedInstance] setTrustTokenWithPendingInvite:_device.trustKey];
            [[AppController sharedInstance] sendInvite:_device.peerID trusted:NO];
            
             
            
            
            break;
        }
        case 1:
        {
            
            break;
        }
        default:
            break;
    }
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
