//
//  FeedImage.m
//  Ribbit
//
//  Created by Steven on 8/9/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "FeedImage.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>

#import <MapKit/MapKit.h>

#import "MRoundedButton.h"
#import "FFCircularProgressView.h"

@interface FeedImage ()
{
    NSString *dateString;
    NSString *locationString;
}

@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) MRoundedButton *likeButton;

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) MRoundedButton *commentButton;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *allComments;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic) CGRect cachedImageViewSize;

@property (nonatomic, strong) UILabel *infoLabel;

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation FeedImage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(BOOL)prefersStatusBarHidden{
    NSLog(@"should hide status bar");
    return YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)backButtonPressed{
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
 
    
    self.currentUser = [PFUser currentUser];
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - 40.0f)];
    
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.backgroundColor = [UIColor colorWithRed:245/255.0 green:240/255.0 blue:235/255.0 alpha:1.0f];
    [self.view addSubview:self.table];
    
    self.table.delegate = self;
    self.table.dataSource = self;

    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - 40.0f,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.toolBar];
    
     self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 6.0f, self.toolBar.bounds.size.width - 20.0f - 68.0f, 30.0f)];

     

    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 6, self.toolBar.bounds.size.width - 20 -68, 30)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.delegate = self;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.toolBar addSubview:self.textField];
    

    
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.sendButton setTitle:@"Post" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.sendButton setEnabled:NO];
    
    self.sendButton.frame = CGRectMake(self.toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [self.sendButton addTarget:self action:@selector(postComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBar addSubview:self.sendButton];
    
    
    self.view.keyboardTriggerOffset = self.toolBar.bounds.size.height;
    
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {

        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        self.toolBar.frame = toolBarFrame;
        
        CGRect tableViewFrame = self.table.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        self.table.frame = tableViewFrame;


    } constraintBasedActionHandler:nil];
    


    PFFile *imageFile = [self.chosenImage objectForKey:@"fileHighRes"];
    NSNumber *likes = [self.chosenImage objectForKey:@"likes"];
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(10, 1, 40, 40);
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadImageWithURL:imageFileUrl
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
        
   
     }
     
     
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageUrl)
     {
         [spinner stopAnimating];
         if (image)
         {
             float y = (image.size.height/image.size.width)*320;
             float barheight = 50;
             
             UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, y)];
             self.table.tableHeaderView = headerView;
             
             self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, y)];
             self.imageView.image = image;
             
             self.cachedImageViewSize = self.imageView.frame;

             
             CGRect infoFrame = CGRectMake(0, y-barheight, 320, barheight);
             UIView *infoBar = [[UIView alloc] initWithFrame:infoFrame];
             infoBar.backgroundColor = [UIColor clearColor];
             
             ILTranslucentView *blurView = [[ILTranslucentView alloc] initWithFrame:infoFrame];
             blurView.translucentAlpha = 1.0f;
             blurView.translucentStyle = UIBarStyleBlack;
             blurView.translucentTintColor = [UIColor clearColor];
             blurView.backgroundColor = [UIColor clearColor];
             
             double buttonWidth = 40;
             double margin = 55;
             
             self.likeButton = [[MRoundedButton alloc] initWithFrame:CGRectMake(margin + 100, (barheight - buttonWidth)/2, buttonWidth, buttonWidth)
                                                                buttonStyle:MRoundedButtonCentralImage
                                                       appearanceIdentifier:@"3"];
        
             
         
             
             self.likeButton.imageView.image = [UIImage imageNamed:@"heart"];
             self.likeButton.backgroundColor = [UIColor clearColor];
             [self.likeButton addTarget:self action:@selector(pictureLiked:) forControlEvents:UIControlEventTouchUpInside];
             
             self.likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.likeButton.frame.origin.x + self.likeButton.frame.size.width, 0, 30, barheight)];
             self.likesLabel.text = [NSString stringWithFormat:@"%d",likes.intValue];
             self.likesLabel.textAlignment = NSTextAlignmentCenter;
             self.likesLabel.textColor = [UIColor whiteColor];
       
             
             
             
             self.commentButton = [[MRoundedButton alloc] initWithFrame:CGRectMake(240 , (barheight - buttonWidth)/2, buttonWidth, buttonWidth)
                                                         buttonStyle:MRoundedButtonCentralImage
                                                appearanceIdentifier:@"2"];
             
             
             
             self.commentButton.imageView.image = [UIImage imageNamed:@"comment"];
             self.commentButton.backgroundColor = [UIColor clearColor];
             [self.commentButton addTarget:self action:@selector(commentButtonPressed) forControlEvents:UIControlEventTouchUpInside];
             
             self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.commentButton.frame.origin.x + self.commentButton.frame.size.width, 0, 30, barheight)];

             self.commentLabel.textAlignment = NSTextAlignmentCenter;
             self.commentLabel.textColor = [UIColor whiteColor];
             
             self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 140, barheight)];
             self.infoLabel.numberOfLines = 2;
             self.infoLabel.textColor = [UIColor whiteColor];
             self.infoLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
             [self getLocation];
             [self.infoLabel setMinimumScaleFactor:.5];
             [self.infoLabel setAdjustsFontSizeToFitWidth:YES];
             
             
             [infoBar addSubview:self.likesLabel];
             [infoBar addSubview:self.likeButton];
             
             [infoBar addSubview:self.commentLabel];
             [infoBar addSubview:self.commentButton];
             
             [infoBar addSubview:self.infoLabel];
             
             [headerView addSubview:self.imageView];
             [headerView addSubview:blurView];
             [headerView addSubview:infoBar];
             
         }
     }];


    
    
    /////////////////////////////////////////////////////////
    //                      APPEARANCES                    //
    /////////////////////////////////////////////////////////
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(320 - 30 - 10, 10, 30, 30)];

    [backButton setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // if decelerating, let scrollViewDidEndDecelerating: handle it

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = -scrollView.contentOffset.y;
    if (y > 0) {
        self.imageView.frame = CGRectMake(0, scrollView.contentOffset.y, self.cachedImageViewSize.size.width+y, self.cachedImageViewSize.size.height+y);
        self.imageView.center = CGPointMake(self.view.center.x, self.imageView.center.y);
    }
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.commentLabel.text = [NSString stringWithFormat:@"%d", self.allComments.count];
    return [self.allComments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"messagingCell";
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}



#pragma mark - Text Field Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (updatedText.length > 0) // 4 was chosen for SSN verification
    {
        [self.sendButton setEnabled:YES];
    }
    
    else{
        [self.sendButton setEnabled:NO];
    }
    
    return YES;
}


#pragma mark - Helper Methods

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell* ccell = (PTSMessagingCell*)cell;
    
    ccell.backgroundColor = [UIColor clearColor];
    ccell.sent = NO;

    [ ccell.avatarImageView setImage:[UIImage imageNamed:@"sample_pic.jpg" ]];
    ccell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
   // ccell.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
   // ccell.avatarImageView.layer.borderWidth = 1.0f;
    ccell.avatarImageView.clipsToBounds = YES;
    ccell.avatarImageView.layer.cornerRadius = 40.0/2.0f;

    ccell.messageLabel.text = [[self.allComments objectAtIndex:indexPath.row] objectForKey:@"commentString"   ];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize messageSize = [PTSMessagingCell messageSize:[[self.allComments objectAtIndex:indexPath.row] objectForKey:@"commentString"   ]];
    NSLog(@"message size %f (%d)", messageSize.height, indexPath.row);
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 30.0f;
}

-(void)pictureLiked:(id)sender
{
    //lets retrieve the image
    
    NSString *imageId = [self.chosenImage objectId];
    NSNumber *likes = [self.chosenImage objectForKey:@"likes" ];
    

    PFUser *user = [PFUser currentUser];
    NSMutableArray *picturesLiked = [user objectForKey:@"picturesLiked"];

    if ([picturesLiked containsObject:imageId]) { // already liked it (UNLIKE)
        [user removeObject:imageId forKey:@"picturesLiked"];
        [user saveInBackground];
        likes = @([likes intValue] - 1);
    
        
        
        self.likesLabel.text = [NSString stringWithFormat:@"%d", [likes intValue]];
   
    }
    else{
        [user addObject:imageId forKey:@"picturesLiked"];
        [user saveInBackground];
        
        likes = @([likes intValue] + 1);
   
        self.likesLabel.text = [NSString stringWithFormat:@"%d", [likes intValue]];
     
    }
    
    [self.chosenImage setObject:likes forKey:@"likes"];
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"objectId" equalTo:imageId];
    
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * post, NSError *error) {
        if (!error) {
            // Found UserStats
            [post setObject:likes forKey:@"likes"];
            [post saveInBackground];
            
        } else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
        }
    }];
}

-(void)postComment:(id)sender
{
    NSString *commentString = self.textField.text;
    self.textField.text = nil;
    self.sendButton.enabled = NO;
    
    
     if (self.table.contentSize.height > self.table.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.table.contentSize.height - self.table.frame.size.height + self.table.rowHeight);
        [self.table setContentOffset:offset animated:YES];
    }

    PFRelation *relation = [self.chosenImage relationForKey:@"comments"];
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    
    [comment setObject:commentString forKey:@"commentString" ];
    [comment setObject:[self.currentUser objectId] forKey:@"posterId"];
    
    FFCircularProgressView *circularPV = [[FFCircularProgressView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-40, 150, 80, 80)];
    [circularPV setAlpha:.5];
    
    [self.view addSubview:circularPV];
    
    [circularPV startSpinProgressBackgroundLayer];
    
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){

        [circularPV setProgress:0];
    });
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {

            [relation addObject:comment];
            [self.chosenImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self refresh];

                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [circularPV stopSpinProgressBackgroundLayer];
                    [circularPV setProgress:1];
                });
                
                dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
                    [circularPV removeFromSuperview];
                });
            }];
        }
    }];
}

-(void)refresh{
    
    PFRelation *relation = [self.chosenImage relationForKey:@"comments"];
    
    PFQuery *query = [relation query];
    query.limit = 300;
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        self.allComments = [NSMutableArray arrayWithArray:results];
        NSLog(@"%@", self.allComments);
        [self.table reloadData];
    }];
}

-(void)commentButtonPressed{
    
    [self.likeButton setHighlighted:YES];
    NSLog(@"comment button pressed");
    [self.textField becomeFirstResponder];
    [self getLocation];
}

#pragma mark - GeoLocation Stuff

-(void)getLocation{
    NSDate *date = [self.chosenImage createdAt];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    dateFormat.doesRelativeDateFormatting = YES;
    
    dateString = [dateFormat stringFromDate:date];
    
    PFGeoPoint *geoPoint = [self.chosenImage objectForKey:@"geoPoint"];
    
    if (geoPoint) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        
        CLLocation *cllocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        
        
        if (self.geocoder == nil)
        {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        
        
        if([self.geocoder isGeocoding])
        {
            [self.geocoder cancelGeocode];
        }
        
        [self.geocoder reverseGeocodeLocation:cllocation completionHandler:^(NSArray *placemarks, NSError *error) {
            NSDictionary *dictionary = [[placemarks objectAtIndex:0] addressDictionary];
            // @"Street" @"City" @"State" @"ZIP"
            
            NSString *city = [dictionary valueForKey:@"City"];
            NSString *state = [dictionary valueForKey:@"State"];
            
            locationString = [NSString stringWithFormat:@"%@, %@", city, state];
            NSLog(@"%@", [NSString stringWithFormat:@"%@, %@", city, state] );
            
            self.infoLabel.text = [NSString stringWithFormat:@"%@\n%@", locationString, dateString];
 
        }];
    }
    
    if (!geoPoint) {
         self.infoLabel.text = [NSString stringWithFormat:@"%@", dateString];
    }
   


}


@end
