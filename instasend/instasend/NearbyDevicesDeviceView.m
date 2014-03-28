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
    _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an action"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    //If this device is trusted, allow different options
    for(NSString* key in [[[AppController sharedInstance] trustedDevices] allObjects])
    {
        if([_device.trustKey isEqualToString:key])
        {
            [_actionSheet addButtonWithTitle:@"Send Photo"];
            [_actionSheet addButtonWithTitle:@"Send Video"];
            [_actionSheet addButtonWithTitle:@"Send Contact"];
            
            
        }
        else
        {
            [_actionSheet addButtonWithTitle:@"Invite"];
            
            
        }
        
    }
    
    
    _actionSheet.cancelButtonIndex = [_actionSheet addButtonWithTitle:@"Cancel"];
    
    [_actionSheet showInView:self];
    
    [[AppController sharedInstance] setActionSheetIsBeingShown:YES];
    
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[AppController sharedInstance] setActionSheetIsBeingShown:NO];
    
    for(NSString* key in [[[AppController sharedInstance] trustedDevices] allObjects])
    {
        if([_device.trustKey isEqualToString:key])
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    //send photo
                    
                    [[AppController sharedInstance] setSelectedDevice:_device];
                   // [[AppController sharedInstance] sendInvite:_device.peerID trusted:YES];
                    
                    [self.delegate selectPhotos:nil];
                    
               
                    
                    
                    break;
                }
                case 1:
                {
                    //send video
                    break;
                }
                case 2:
                {
                    //send contact
                    break;
                }
                default:
                    break;
            }
            
            
        }
        else
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    //invite
                    [[AppController sharedInstance] setTrustTokenWithPendingInvite:_device.trustKey];
                   // [[AppController sharedInstance] sendInvite:_device.peerID trusted:NO];
                    
                    
                    
                    
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
        
    }
    
    
    
    
}

-(void)cancelActionSheet
{
    if(_actionSheet)
    {
        [_actionSheet dismissWithClickedButtonIndex:2 animated:YES];
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
