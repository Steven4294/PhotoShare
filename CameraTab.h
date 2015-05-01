//
//  CameraTab.h
//  Ribbit
//
//  Created by Steven on 8/3/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DBCameraContainerViewController.h"
#import "SDSegmentedControl.h"



@interface CameraTab : UIViewController <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate,
DBCameraViewControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SDSegmentedControl *senderControl;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *recipients;

@property (nonatomic, strong) IBOutlet UILabel *label1;
@property (nonatomic, strong) IBOutlet UILabel *label2;

@property (nonatomic, retain) CLLocationManager *locationManager;


- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)segmentDidChange:(id)sender;

- (void)uploadMessage;
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;


@end
