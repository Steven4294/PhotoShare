//
//  MessageCell.m
//  Ribbit
//
//  Created by Steven on 8/2/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.container.clipsToBounds = YES;
    self.container.layer.cornerRadius = self.container.frame.size.width/2;
 

}

-(void) drawRect:(CGRect)rect{
    
    self.container.clipsToBounds = YES;
    self.container.layer.cornerRadius = self.container.frame.size.width/2;
    
    self.container.layer.borderColor = [UIColor colorWithRed:70/255.0 green:87/255.0 blue:112/255.0 alpha:1.0].CGColor;
    // self.container.layer.borderColor = [UIColor greenColor].CGColor ;

}

@end
