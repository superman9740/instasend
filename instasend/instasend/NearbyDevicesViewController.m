//
//  NearbyDevicesViewController.m
//  instasend
//
//  Created by sdickson on 3/19/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import "NearbyDevicesViewController.h"
#import "AppController.h"
#import "Device.h"


@interface NearbyDevicesViewController ()

@end

@implementation NearbyDevicesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
      
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViews:) name:kRefreshDevicesView object:nil];
    
    
}

-(IBAction)refreshViews:(id)sender
{
    [_tableView reloadData];
    
    
}



#pragma mark - UITableView delegate/datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = [[[AppController sharedInstance] devices] count];
    
    return count;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *MyIdentifier = @"nearbyCell";
    
    NearbyDevicesTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[NearbyDevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
        
        
    }
    
   cell.deviceGroup.text = @"iOS";
   //ScrollView
    NSMutableArray* devices = [[AppController sharedInstance] devices];
    int xPos = 0;
    NSArray* viewObjs = cell.scrollView.subviews;
    
    for(UIView* viewObj in  viewObjs )
    {
        [viewObj removeFromSuperview ];
        
    }
    
    for (Device* dev in devices)
    {
        
        
        CGRect frame;
        frame.origin.x = xPos;
        frame.size.height = 80;
        frame.size.width = 80;
        
        NearbyDevicesDeviceView* subview = [[NearbyDevicesDeviceView alloc] initWithFrame:frame];
        subview.layer.borderColor = [[UIColor grayColor] CGColor];
        subview.layer.borderWidth = 1;
        subview.layer.cornerRadius = 4;
        //Register tap gesture
        subview.device = dev;
        for(NSString* key in [[[AppController sharedInstance] trustedDevices] allObjects])
        {
            if([dev.trustKey isEqualToString:key])
            {
                subview.layer.borderColor = [[UIColor greenColor] CGColor];
                
                
            }
            
        }
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:subview action:@selector(showDeviceActionSheet:)];
        [subview addGestureRecognizer:tapGesture];
        
        
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone.png"]];
        CGRect imageRect = CGRectMake(18,10, 40, 40);
        imageView.frame = imageRect;
        
        [subview addSubview:imageView];
        
        
        UILabel* deviceName = [[UILabel alloc] initWithFrame:CGRectMake(5,60,100,15)];
        deviceName.textColor = [UIColor blackColor];
        deviceName.font = [UIFont fontWithName:@"Helvetica" size:12];
        
        deviceName.text = dev.deviceName;
        
        [subview addSubview:deviceName];
        
        //subview.contentMode = UIViewContentModeScaleToFill;
        
        //subview.image = image;
        
        [cell.scrollView addSubview:subview];
        xPos += 90;
        
    }
    
    
    cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width * [devices count], cell.scrollView.frame.size.height);
    
 
   
    
    return cell;
}






@end
