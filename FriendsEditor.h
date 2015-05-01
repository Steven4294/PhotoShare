//
//  FriendsEditor.h
//  Ribbit
//
//  Created by Steven on 7/30/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HMSegmentedControl.h"



@interface FriendsEditor : UIViewController <UITableViewDelegate, UITableViewDataSource>

// UI elements
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITableView *table2;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) PFUser *currentUser;

// parse variables
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *friendrequest;




- (BOOL)isFriend:(PFUser *)user;

@end
