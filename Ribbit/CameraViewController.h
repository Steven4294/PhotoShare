//
//  CameraViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DBCameraContainerViewController.h"


@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, DBCameraViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UISegmentedControl *senderControl;


@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *publicForm;


- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)segmentDidChange:(id)sender;

- (void)uploadMessage;
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;

@end
