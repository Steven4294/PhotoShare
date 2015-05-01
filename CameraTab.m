//
//  CameraTab.m
//  Ribbit
//
//  Created by Steven on 8/3/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "CameraTab.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>

#import "MessageCell.h"
//#import "UIView+LayerEffects.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>


#import "UIImage+ImageCompress.h"   
#import "UIImage+Resize.h"

//#import "BOSImageResizeOperation.h"

@interface CameraTab (){
    
    BOOL isPublic;
    
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *publicForm;
@property (nonatomic, strong) UIButton *submit_public;
@property (nonatomic, strong) UIButton *submit_private;
@property (nonatomic, strong) PFGeoPoint *geoPoint;


@end

@implementation CameraTab

UIColor *disclosureColor;

-(CLLocationManager *)locationManager{
    NSLog(@"location Manager being initted");
    if (_locationManager != nil) {
        return _locationManager;
    }

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.delegate = self;
    _locationManager.purpose = @"Only your city will be displayed (e.g. Boston)";
	
	return _locationManager;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations objectAtIndex:0];
	CLLocationCoordinate2D coordinate = [location coordinate];
    self.geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];

    self.recipients = [[NSMutableArray alloc] init];
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    float height = 96;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, height, 320, self.view.frame.size.height-height )];  //0 - 173 - 320 - 395//
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(640, 200);
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 200) animated:NO];
    
    self.publicForm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height)];
    self.publicForm.backgroundColor = [UIColor whiteColor];

    SDSegmentedControl *segmentedControlAppearance = SDSegmentedControl.appearance;
    segmentedControlAppearance.backgroundColor = [UIColor colorWithRed:27/255.0 green:30/255.0 blue:33/255.0 alpha:1.0f];
    
    SDSegmentView *segmenteViewAppearance = SDSegmentView.appearance;
  
   [segmenteViewAppearance setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0f]  forState:UIControlStateNormal];
   [segmenteViewAppearance setTitleColor:[UIColor colorWithRed:55/255.0 green:154/255.0 blue:234/255.0 alpha:1.0f]   forState:UIControlStateSelected];
   [segmenteViewAppearance setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0f]  forState:UIControlStateDisabled];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, self.scrollView.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tag = 1;

    
    UIButton *submitPublic = [[UIButton alloc] initWithFrame:CGRectMake(0, self.publicForm.frame.size.height - 47.5, 320, 47.5)];
    [submitPublic setImage:[UIImage imageNamed:@"Button_Public"] forState:UIControlStateNormal  ];
    [submitPublic addTarget:self action:@selector(submitPublic) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *submitPrivate = [[UIButton alloc] initWithFrame:CGRectMake(320, self.publicForm.frame.size.height - 47.5, 320, 47.5)];
    [submitPrivate setImage:[UIImage imageNamed:@"Button_Private"] forState:UIControlStateNormal  ];
    [submitPrivate addTarget:self action:@selector(submitPrivate) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.publicForm];
    [self.scrollView addSubview:self.tableView];
    [self.publicForm addSubview:submitPublic];
    [self.scrollView addSubview:submitPrivate];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    NSLog(@"view will appear");
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
    
    DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
    [cameraContainer setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:NO completion:nil];
    
}
#pragma mark - Scroll View Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x < 160) { 
        [self.senderControl setSelectedSegmentIndex:0  ];
        
    }
    else{
        [self.senderControl setSelectedSegmentIndex:1  ];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x < 0) {
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y)];
    }
    if (scrollView.contentOffset.x > 320) {
        [self.scrollView setContentOffset:CGPointMake(320, self.scrollView.contentOffset.y)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"MessageCell";
    
    MessageCell *cell = (MessageCell * ) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }

    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.name.text = [user objectForKey:@"name"];
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.icon.image = [UIImage imageNamed:@"Check_icon"];
    }
    else {
        cell.icon.image = [UIImage imageNamed:@"Bar Color"];
    }
    
    cell.tag = 0;
    
    return cell;
}

#pragma mark - Table view delegate // fix this!!!

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MessageCell *cell = (MessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (cell.tag == 0) {
        cell.tag = 1;
        cell.icon.image = [UIImage imageNamed:@"Check_icon"];
        [self.recipients addObject:user.objectId];
    }
    else {
        
        cell.icon.image = [UIImage imageNamed:@"Bar Color"];
        cell.tag = 0;
        [self.recipients removeObject:user.objectId];
    }
    
    NSLog(@"%@", self.recipients);
}

#pragma mark - IBActions

- (IBAction)cancel:(id)sender {
    [self reset];
    [self.tabBarController setSelectedIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)send:(id)sender {
  
}

#pragma mark - Helper methods

- (void)uploadMessage {
    NSData *fileData;
    NSData *fileDataHighRes;
    NSString *fileName;
    NSString *fileNameHighRes;
    NSString *fileType;
    NSNumber *fileHeight;
    NSValue *fileWidth;

    if (self.image != nil) {
       // double compressionRatio=0.0;
        UIImage *newImage = self.image;
        UIImage *newImageHighRes = self.image;
        
        double x = 160, y = 160;
        
        if (newImage.size.height > newImage.size.width) { // should be in good shape

            y = (newImage.size.height/newImage.size.width) * x;
        }
        else{
            x = (newImage.size.width/newImage.size.height) * y;
        }
        
        newImage = [newImage scaleImageToSize:CGSizeMake(x, y)];
        newImageHighRes = [newImageHighRes scaleImageToSize:CGSizeMake(2*x, 2*y)];
        
        fileData = UIImageJPEGRepresentation(newImage, .8);
        fileDataHighRes = UIImageJPEGRepresentation(newImageHighRes, .8);
        fileName = @"image.png";
        fileNameHighRes = @"image@2x.png";
        fileType = @"image";
        fileHeight =  [NSNumber numberWithFloat:self.image.size.height];
        fileWidth =  [NSNumber numberWithFloat:self.image.size.width];
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    PFFile *fileHighRes = [PFFile fileWithName:fileNameHighRes data:fileDataHighRes];
    

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        NSLog(@"message uploaded!");
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                message:@"Please try sending your message again."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else {
            if (isPublic == NO) {
                PFObject *message = [PFObject objectWithClassName:@"Messages"];
                [message setObject:file forKey:@"file"];
                [message setObject:fileHighRes forKey:@"fileHighRes"];
                [message setObject:fileType forKey:@"fileType"];
                [message setObject:self.recipients forKey:@"recipientIds"];
                [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
                [message setObject:fileWidth forKey:@"fileWidth"];
                [message setObject:fileHeight forKey:@"fileHeight"];
                
                [message setObject: [[PFUser currentUser] objectForKey:@"name"] forKey:@"senderName"];
                [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                            message:@"Please try sending your message again."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    else {
                        // Everything was successful!
                        [self reset];
                    }
                }];
            }
            else{// public TO FEED!
                
                PFObject *message = [PFObject objectWithClassName:@"Messages"];
                [message setObject:file forKey:@"file"];
                [message setObject:fileHighRes forKey:@"fileHighRes"];
                [message setObject:fileType forKey:@"fileType"];
                [message setObject:[NSNumber numberWithBool:isPublic] forKey:@"isPublic"];
                [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
                [message setObject:fileWidth forKey:@"fileWidth"];
                [message setObject:fileHeight forKey:@"fileHeight"];
                [message setObject:self.geoPoint forKey:@"geoPoint"];
                
                [message setObject: [[PFUser currentUser] objectForKey:@"name"] forKey:@"senderName"];
                [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                            message:@"Please try posting your message again."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    else {
                        // Everything was successful!
                        [self reset];
                    }
                }];
            }
        }
    }];
}

- (IBAction)segmentDidChange:(id)sender{
    
    
    __weak typeof(self) weakSelf = self;
    
    
    NSInteger index = self.senderControl.selectedSegmentIndex;
    
    [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];

}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
    
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
    [self reset];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{   NSLog(@"delegate camera");
    
    self.image = image;
    
    NSLog(@"meta data: %@", metadata);

    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Submission Methods

-(void)submitPublic{
    
    isPublic = YES;
    [self sendMessage];
    
}

-(void)submitPrivate{
    isPublic = NO;
    [self sendMessage];
}

-(void)sendMessage{
    
    if (self.image == nil) {
        NSLog(@"image blank");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try again!"
                                                            message:@"Please capture or select a photo or video to share!"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        // [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    
    else {
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - helper



- (UIImage *) scaleAndRotateImage: (UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
}

@end
