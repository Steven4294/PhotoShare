//
//  FeedCollection.h
//  Ribbit
//
//  Created by Steven on 8/15/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "NJKScrollFullScreen.h"
#import "UIViewController+NJKFullScreenSupport.h"

#import "ICGViewController.h"
#import "ICGNavigationController.h"
@interface FeedCollection : ICGViewController <UICollectionViewDelegate, UICollectionViewDataSource, NJKScrollFullscreenDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) PFObject *feedImage;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
