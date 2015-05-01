//
//  FriendsEditor.m
//  Ribbit
//
//  Created by Steven on 7/30/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "FriendsEditor.h"

#import "NewFriendTableViewCell.h"
#import "FriendRequestCell.h"


@interface FriendsEditor ()

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@end

@implementation FriendsEditor



UIColor *disclosureColor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friendrequest = [[NSMutableArray alloc] init];
    
    self.title = @"DAKeyboardControl";

    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.allUsers = objects;
            [self.table reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    

    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 80, 320, 50)];
    self.segmentedControl.sectionTitles = @[@"Followers", @"Search"];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = [UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    self.segmentedControl.textColor = [UIColor blackColor];
    self.segmentedControl.selectedTextColor = [UIColor whiteColor];
    
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    self.segmentedControl.tag = 3;
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(320 * index, 0, 320, 200) animated:YES];
    }];
    
    
    [self.view addSubview:self.segmentedControl];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 173, 320, 395 )];  //0 - 173 - 320 - 395//
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(640, 200);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 200) animated:NO];
    [self.view addSubview:self.scrollView];
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, self.scrollView.frame.size.height)];
   [self.scrollView addSubview:self.table];

    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.tag = 1;
  
   self.table2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollView.frame.size.height)];
    [self.scrollView addSubview:self.table2];
    
    self.table2.delegate = self;
    self.table2.dataSource = self;
    self.table2.tag = 2;

    [self FriendRequests];

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 2) {
        NSLog(@"numb %d", self.friendrequest.count);
        return [self.friendrequest count];
        
    }

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSLog(@"Rows %d", [self.searchResults count]);
            return [self.searchResults count];
            
        }
        else{
            NSLog(@"Rows %d", [self.allUsers count]);
            return [self.allUsers count];
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 1 || tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *CellIdentifier = @"NewFriendTableViewCell";
        
        NewFriendTableViewCell *cell = (NewFriendTableViewCell * ) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"NewFriendTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        
        PFUser *user;
        
        if (tableView == self.searchDisplayController.searchResultsTableView){
            user = [self.searchResults objectAtIndex:indexPath.row];
            
        }
        else{
            user = [self.allUsers objectAtIndex:indexPath.row];
        }
        
        cell.name.text = [user objectForKey:@"name"];
        
        if ([self isFriend:user]) {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconFull"];
        }
        else {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconEmpty"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
        
    }
    else if (tableView.tag == 2) { // create cells for requests
        static NSString *CellIdentifier = @"FriendRequestCell";
        
        FriendRequestCell *cell = (FriendRequestCell * ) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"FriendRequestCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        
        PFUser *user = [self.friendrequest objectAtIndex:indexPath.row];
        
        if ([self isFriend:user]) {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconFull"];
        }
        else {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconEmpty"];
        }
        cell.name.text = [user objectForKey:@"name"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
//   return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView.tag == 1 || tableView == self.searchDisplayController.searchResultsTableView) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            
            NSLog(@"Search index %d", indexPath.row);
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            
        }
        else{
            NSLog(@"reg index %d", indexPath.row);
            [self.table deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        NewFriendTableViewCell *cell = (NewFriendTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];
        
        PFUser *user;
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            user = [self.searchResults objectAtIndex:indexPath.row];
        }
        else{
            user = [self.allUsers objectAtIndex:indexPath.row];
        }
        
        if ([self isFriend:user]) {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconEmpty"];
            NSLog(@"friend");
            for(PFUser *friend in self.friends) {
                if ([friend.objectId isEqualToString:user.objectId]) {
                    [self.friends removeObject:friend];
                    break;
                }
            }
            
            [friendsRelation removeObject:user];
        }
        else {
            
            
            cell.icon.image = [UIImage imageNamed:@"newFriendIconFull"];
            [self.friends addObject:user];
            [friendsRelation addObject:user];
            
        }
        
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    else if (tableView.tag == 2){

      
        [self.table deselectRowAtIndexPath:indexPath animated:NO];
     
        
        FriendRequestCell *cell = (FriendRequestCell *)[tableView cellForRowAtIndexPath:indexPath];
        PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];
        
        PFUser *user = [self.friendrequest objectAtIndex:indexPath.row];
        
        
        if ([self isFriend:user]) {
            cell.icon.image = [UIImage imageNamed:@"newFriendIconEmpty"];
            NSLog(@"friend");
            for(PFUser *friend in self.friends) {
                if ([friend.objectId isEqualToString:user.objectId]) {
                    [self.friends removeObject:friend];
                    break;
                }
            }
            
            [friendsRelation removeObject:user];
        }
        else {
            
            cell.icon.image = [UIImage imageNamed:@"newFriendIconFull"];
            [self.friends addObject:user];
            [friendsRelation addObject:user];
        }
        
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}


#pragma mark - Search Display Delegates

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - Helper methods

- (BOOL)isFriend:(PFUser *)user {

    for(PFUser *friend in self.friends) {
        
        
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    
    self.searchResults = [self.allUsers filteredArrayUsingPredicate:resultPredicate];
}


-(void)FriendRequests{

    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    [query whereKey:@"friendsRelation" equalTo: self.currentUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error %@", error);
        }
        else{
            self.friendrequest = objects;
            NSLog(@"objects found %d", self.friendrequest.count );
            [self.table2 reloadData];
        }
    }];
}

@end
