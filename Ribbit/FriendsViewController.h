//
//  FriendsViewController.h
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SWTableViewCell.h"



@interface FriendsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>


@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friends;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

-(IBAction)NewFriendPressed:(id)sender;

@end
