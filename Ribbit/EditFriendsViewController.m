//
//  EditFriendsViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "MSCellAccessory.h"
#import "GravatarUrlBuilder.h"
#import "NewFriendTableViewCell.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

UIColor *disclosureColor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.tableView.backgroundColor = [UIColor clearColor];
    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    static NSString *CellIdentifier = @"Cell";
    NewFriendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.profilepic.image = [UIImage imageNamed:@"user_icon"];
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
        cell.icon.image = [UIImage imageNamed:@"newFriendIcon"];
    }
    
    //////////////////////////////////////
    // IF PFUser *user == Facebook User //
    
    NSNumber *onFacebook = [user objectForKey:@"onFacebook"];
    NSLog(@"onFacebook : %d", onFacebook.integerValue);
    

    if (onFacebook.integerValue == 1) {
        FBRequest *request = [FBRequest requestForMe];
        //cell.textLabel.text = @"";
        
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                // Parse the data received
                NSDictionary *userData = (NSDictionary *)result;
                NSString *facebookID = userData[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                
                NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                
                if (facebookID) {
                    userProfile[@"facebookId"] = facebookID;
                }
                
                if (userData[@"name"]) {
                    userProfile[@"name"] = userData[@"name"];
                }
                
                if (userData[@"location"][@"name"]) {
                    userProfile[@"location"] = userData[@"location"][@"name"];
                }
                
                if (userData[@"gender"]) {
                    userProfile[@"gender"] = userData[@"gender"];
                }
                
                if (userData[@"birthday"]) {
                    userProfile[@"birthday"] = userData[@"birthday"];
                }
                
                if (userData[@"relationship_status"]) {
                    userProfile[@"relationship"] = userData[@"relationship_status"];
                }
                
                if ([pictureURL absoluteString]) {
                    userProfile[@"pictureURL"] = [pictureURL absoluteString];
                }
                
                cell.name.text = userData[@"name"];
                
                
                NSURL *profileURL = [NSURL URLWithString:userProfile[@"pictureURL"]];
                NSData *imageData = [NSData dataWithContentsOfURL:profileURL];
                cell.profilepic.image = [UIImage imageWithData:imageData];


                
                [cell setNeedsLayout];
                
        
                [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
                [[PFUser currentUser] saveInBackground];
                
                //[self updateProfile];//
            }
            else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                NSLog(@"The facebook session was invalidated");
                //[self logoutButtonTouchHandler:nil];//
            }
            else {
                NSLog(@"Some other error: %@", error);
            }
        }];
    }
    
    /*
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        // 1. Get email address
        NSString *email = [user objectForKey:@"email"];
        
        // 2. Create the md5 hash
        NSURL *gravatarUrl = [GravatarUrlBuilder getGravatarUrl:email];
        
        // 3. Request the image from Gravatar
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarUrl];
        
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 4. Set image in cell
                cell.imageView.image = [UIImage imageWithData:imageData];
                [cell setNeedsLayout];
            });
        }
    });
    */
    

    
    return cell;
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NewFriendTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    

    PFRelation *friendsRelation = [self.currentUser relationforKey:@"friendsRelation"];
    PFUser *user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    }
    else{
        user = [self.allUsers objectAtIndex:indexPath.row];
    }

    if ([self isFriend:user]) { //remove friend
        cell.icon.image = [UIImage imageNamed:@"newFriendIcon"];
        
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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

@end
