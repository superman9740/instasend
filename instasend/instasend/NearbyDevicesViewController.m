//
//  NearbyDevicesViewController.m
//  instasend
//
//  Created by sdickson on 3/19/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import "NearbyDevicesViewController.h"
#import "AppController.h"
#import "NearbyDeviceCollectionViewCell.h"

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
  //  [self.collectionView registerClass:[NearbyDeviceCollectionViewCell class] forCellWithReuseIdentifier:@"nearbyCell"];
    
    
}



#pragma mark - UICollectionView Datasource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger val = [[[AppController sharedInstance] devices] count];
    
    return val;
    
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    
    NearbyDeviceCollectionViewCell* cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"nearbyCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 3;
    cell.layer.borderColor = [[UIColor grayColor] CGColor];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
    imageView.image = [UIImage imageNamed:@"iphone.png"];
  //  [cell.contentView addSubview:imageView];
    
    
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
