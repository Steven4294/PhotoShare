//
//  FeedViewController.m
//  Ribbit
//
//  Created by Steven on 8/3/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "FeedViewController.h"
#import "MHFacebookImageViewer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FeedCell.h"
#import <UIViewController+ScrollingNavbar.h>


@interface FeedViewController ()

@end

@implementation FeedViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrieveMessages];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged];
 //   self.tableView.separatorColor = [UIColor clearColor];
    
    [self followScrollView:self.tableView];
    

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
    return  [self.messages count]/2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"(%d) messages %@", [self.messages count], self.messages);
    
    NSString *cellIdentifier = @"cell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    self.feedImage1 = [self.messages objectAtIndex:2*indexPath.row];
    self.feedImage2 = [self.messages objectAtIndex:2*indexPath.row + 1];
    
    
    PFFile *imageFile = [self.feedImage1 objectForKey:@"file"];
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
    PFFile *imageFile2 = [self.feedImage2 objectForKey:@"file"];
    NSURL *imageFileUrl2 = [[NSURL alloc] initWithString:imageFile2.url];
    
    [cell.image1 sd_setImageWithURL:imageFileUrl placeholderImage:[UIImage imageNamed:@"user_icon"] completed:nil];
    [cell.image2 sd_setImageWithURL:imageFileUrl2 placeholderImage:[UIImage imageNamed:@"user_icon"] completed:nil];
    

    
    
    
    
    NSLog(@"row %d, image 1:  %@", indexPath.row, self.feedImage1);
    NSLog(@"row %d, image 2:  %@", indexPath.row, self.feedImage2);
   // [cell.image1 sd_setImageWithURL:[NSURL urlhere] placeholderImage:[UIImage imageNamed:@"sample_pic"] completed:nil];
    
    return cell;
}




#pragma mark - helper methods

- (void) displayImage:(UIImageView*)imageView withImage:(UIImage*)image  {
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setupImageViewer];
    imageView.clipsToBounds = YES;
}


# pragma mark - Helper methods

- (void)retrieveMessages {
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"isPublic" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            // We found messages!
            self.messages = objects;
            [self.tableView reloadData];
            NSLog(@"Retrieved %d messages", [self.messages count]);
        }
        
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
}


@end
