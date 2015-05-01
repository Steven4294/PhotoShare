//

#import "FeedCollection.h"
#import "FeedCollectionCell.h"

#import "SDWebImagePrefetcher.h"

#import "FeedImage.h"
#import "Haneke.h"
#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"
#import "UIScrollView+UzysCircularProgressPullToRefresh.h"
#import "TLYShyNavBarManager.h"

@interface FeedCollection ()
{
    
    int totalBytes;
    
}

@property (nonatomic) NJKScrollFullScreen *scrollProxy;
@property (nonatomic, strong) NSMutableArray *imageCache;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, strong) NSMutableArray *objectIds;
@property (assign, nonatomic) BOOL loadingMore;


@end

@implementation FeedCollection


+ (void)initialize
{
    HNKCacheFormat *format = [[HNKCacheFormat alloc] initWithName:@"thumbnail"];
    
    format.compressionQuality = 0.5;
    // UIImageView category default: 0.75, -[HNKCacheFormat initWithName:] default: 1.
    
    format.allowUpscaling = YES;
    // UIImageView category default: YES, -[HNKCacheFormat initWithName:] default: NO.
    
    format.diskCapacity = 0.5 * 1024 * 1024;
    // UIImageView category default: 10 * 1024 * 1024 (10MB), -[HNKCacheFormat initWithName:] default: 0 (no disk cache).
    
    format.preloadPolicy = HNKPreloadPolicyLastSession;
    // Default: HNKPreloadPolicyNone.
    
    format.scaleMode = HNKScaleModeAspectFill;
    // UIImageView category default: -[UIImageView contentMode], -[HNKCacheFormat initWithName:] default: HNKScaleModeFill.
    
    format.size = CGSizeMake(100, 100);
    // UIImageView category default: -[UIImageView bounds].size, -[HNKCacheFormat initWithName:] default: CGSizeZero.
    
    
    [[HNKCache sharedCache] registerFormat:format];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objectIds = [[NSMutableArray alloc] init];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;


    
    
    [self retrieveMessages];
    
    _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self];
    self.collectionView.delegate = (id)_scrollProxy;
    _scrollProxy.delegate = self;
    
    double statusBarHeight = 0;
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.navigationController.navigationBar.frame.size.height + statusBarHeight)];
    headerView.backgroundColor = [UIColor greenColor];
    // self.tableView.tableHeaderView = headerView;
    
    totalBytes = 0;
    
        __weak FeedCollection *weakSelf = self;
    
    // setup pull-to-refresh

    
    // setup infinite scrolling
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    UIView *underBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    underBar.backgroundColor = [UIColor whiteColor];
    
    self.shyNavBarManager.scrollView = self.collectionView;
    [self.shyNavBarManager setExtensionView: underBar];
}



- (void)didReceiveMemoryWarning
{
    NSLog(@"clearing cache!?!");
    totalBytes = 0;
    return;
    //  [super didReceiveMemoryWarning];
}

#pragma mark - Collection View

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *cellIdentifier = @"Cell";
    
    FeedCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    if (!cell) {
        
        cell = [[FeedCollectionCell alloc] init];
        
    }
    
    self.feedImage = [self.messages objectAtIndex:indexPath.row];
    PFFile *imageFile = [self.feedImage objectForKey:@"file"];
    NSURL *url = [[NSURL alloc] initWithString:imageFile.url];
    NSURL *url2 = [[NSURL alloc] initWithString:@"http://www.adimec.com/content/wysiwyg/resizedmedia/3746_160x160/160x160-Kuni.jpg"];
    [cell.button addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [cell.imageView sd_setImageWithURL:url placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (cacheType == (SDImageCacheTypeDisk || SDImageCacheTypeNone)) {
            
            cell.imageView.alpha = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.imageView.alpha = 1;
            }];
        }
        if (cacheType == SDImageCacheTypeMemory) {
            
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSData *originalData = [NSData dataWithContentsOfURL:url];
            totalBytes = totalBytes + data.length;
            NSLog(@"%d: %d -> %d",indexPath.row, originalData.length , data.length );
        });
    }];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.messages count];
    
}



# pragma mark - Helper methods

- (void)retrieveMessages {
    NSLog(@"refreshed");
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"isPublic" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"createdAt"];
    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            //NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // We found messages!
            self.messages = [objects mutableCopy];
            [self.collectionView reloadData];
            
            self.urls = [NSMutableArray arrayWithCapacity:self.messages.count];
            
            for (NSDictionary *message in self.messages) {
                PFFile *file = [message objectForKey:@"file"];
                [self.urls addObject:[[NSURL alloc] initWithString:file.url] ];
                PFObject *object = (PFObject *)message;
                [self.objectIds addObject:[object objectId]];
            }
            //NSLog(@"Retrieved %d messages", [self.messages count]);
        }
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
}

#pragma mark - add more data!

- (void)insertRowAtBottom {
    // need to set up a PFQuery?
    NSLog(@"adding 4 objects");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"isPublic" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"objectId" notContainedIn:self.objectIds];
    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            //NSLog(@"Error: %@ %@", error, [error userInfo]);
            NSLog(@"error");
        }
        else {
            // We found messages!
            [self.collectionView.infiniteScrollingView stopAnimating];
            NSLog(@"loaded: %d", objects.count);
            [self.messages addObjectsFromArray:objects];
        
            
            self.urls = [NSMutableArray arrayWithCapacity:self.messages.count];
            
            for (NSDictionary *message in self.messages) {
                PFFile *file = [message objectForKey:@"file"];
                [self.urls addObject:[[NSURL alloc] initWithString:file.url] ];
                PFObject *object = (PFObject *)message;
                [self.objectIds addObject:[object objectId]];
            }
            [self.collectionView reloadData];
        }
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
    
    
   }


- (void)loadMore
{
    /*    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:self.urls progress:^(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls) {
     // progress
     
     } completed:^(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls) {
     // completed
     self.loadingMore = NO;
     }];*/
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    /*
     for(FeedCollectionCell *view in self.collectionView.visibleCells) {
     CGFloat yOffset = ((self.collectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
     view.imageOffset = CGPointMake(0.0f, yOffset);
     }*/
}

#pragma mark NJKScrollFullScreenDelegate

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
{
  //  [self moveNavigtionBar:deltaY animated:YES];
    [self moveToolbar:-deltaY animated:YES]; // move to revese direction
    [self moveTabBar:-deltaY animated:YES];
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
{
  //  [self moveNavigtionBar:deltaY animated:YES];
    [self moveToolbar:-deltaY animated:YES];
    [self moveTabBar:-deltaY animated:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
{
  //  [self hideNavigationBar:YES];
    [self hideToolbar:YES];
    [self hideTabBar:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
{
    //[self showNavigationBar:YES];
    [self showToolbar:YES];
    [self showTabBar:YES];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollProxy reset];
   // [self showNavigationBar:YES];
    [self showToolbar:YES];
    [self showTabBar:YES];
}

- (void)imageTouched:(id)sender{
    
    NSLog(@"image touched");
    
    FeedImage *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"feedimage"];
    
    ICGViewController *fancyViewController = (ICGViewController *) self;
    
    fancyViewController.interactionEnabled = YES;
    NSString *className = [NSString stringWithFormat:@"ICGSlideAnimation"];
    id transitionInstance = [[NSClassFromString(className) alloc] init];
    fancyViewController.animationController = transitionInstance;
    fancyViewController.animationController.type = 1;
    
    self.transitioningDelegate = fancyViewController;
    
    NSLog(@"modal %@", fancyViewController.animationController);
    
    if ([self respondsToSelector:@selector(setTransitioningDelegate:)]){
        viewController.transitioningDelegate = self.transitioningDelegate;  // this is important for the animation to work
        NSLog(@"transition delegate set");
        
    }
    
    CGPoint pointInCollectionView = [sender convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
    PFObject *imageLiked = [self.messages objectAtIndex:indexPath.row];
    viewController.chosenImage = imageLiked;
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

@end
