//
//  InboxCell.h
//  Ribbit
//
//  Created by Steven on 7/30/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "SWTableViewCell.h"

@interface InboxCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UILabel *sender;
@property (nonatomic, weak) IBOutlet UILabel *time;

@end
