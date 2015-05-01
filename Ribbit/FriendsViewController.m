//
//  FriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "SPTableViewCell.h"
#import "FriendsEditor.h"

@interface FriendsViewController ()
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateFriends) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateFriends];
    

}


-(IBAction)NewFriendPressed:(id)sender{
    
    FriendsEditor *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"bottom"];
    viewController.friends = [NSMutableArray arrayWithArray:self.friends];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:viewController];
    self.animator.dragable = YES;
    
    /*
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8f;
    self.animator.behindViewScale = 1.0f;
     */
    
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setCompletionCurve:UIViewAnimationCurveLinear];
    [self.animator setContentScrollView:viewController.table ];

    
    viewController.transitioningDelegate = self.animator;
    [self presentViewController:viewController animated:YES completion:nil];
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
    static NSString *CellIdentifier = @"Cell";
    SPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.0f];
    cell.delegate = self;
    cell.profilepic.image = [UIImage imageNamed:@"user_icon"];
    
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    //cell.textLabel.text = [user objectForKey:@"name"];
    cell.name.text = [user objectForKey:@"name"];
    
    NSNumber *onFacebook = [user objectForKey:@"onFacebook"];
    
    if (onFacebook.integerValue == 1) {
   
        NSDictionary *userData = (NSDictionary *)user;
        NSURL *pictureURL = [NSURL URLWithString:[[userData objectForKey:@"profile"] objectForKey:@"pictureURL"]];
        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
        NSLog(@"%@", pictureURL);
        
       // cell.imageView.image = [UIImage imageWithData:imageData];
        cell.profilepic.image = [UIImage imageWithData:imageData];
        
        [cell setNeedsLayout];
        
    }
    else{
        
        // cell gets default pic?
    }
    

    
    //cell.imageView.image = [UIImage imageNamed:@"icon_person"];
    
    return cell;
}


#pragma mark - Helper methods

-(void)updateFriends{
    
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
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (NSArray *)rightButtons
{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"cross.png"]];
    
    return rightUtilityButtons;
}



#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            // Delete Cell
      
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            PFUser *currentUser = [PFUser currentUser];
            PFRelation *friendsRelation = [currentUser relationforKey:@"friendsRelation"];
            PFUser *friendRemoved;
            friendRemoved = [self.friends objectAtIndex:(cellIndexPath.row)];
            
            NSLog(@"friends to be deleted: %@", friendRemoved);
     
            [friendsRelation removeObject:friendRemoved];

            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];

            [self.friends removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
            break;
        }
        case 1:
        {
            // Delete button was pressed
        
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}


@end








