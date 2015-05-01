//
//  FeedImage.h
//  Ribbit
//
//  Created by Steven on 8/9/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DAKeyBoardControl.h"
#import "PTSMessagingCell.h"
#import "ILTranslucentView.h"



@interface FeedImage : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, strong) PFObject *chosenImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *table;



@end
