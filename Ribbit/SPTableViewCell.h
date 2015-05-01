//
//  SPTableViewCell.h
//  Ribbit
//
//  Created by Steven on 7/30/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "SWTableViewCell.h"

// FRIEND LIST //

@interface SPTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
