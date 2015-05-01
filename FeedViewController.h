//
//  FeedViewController.h
//  Ribbit
//
//  Created by Steven on 8/3/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface FeedViewController : UITableViewController

@property (nonatomic, strong) PFObject *feedImage1;
@property (nonatomic, strong) PFObject *feedImage2;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
