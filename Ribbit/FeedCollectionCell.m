//
//  FeedCollectionCell.m
//  Ribbit
//
//  Created by Steven on 8/15/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "FeedCollectionCell.h"

@interface FeedCollectionCell()

// private properties

@end

@implementation FeedCollectionCell



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setupImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setupImageView];
    return self;
}


 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
     
     self.imageView.layer.borderColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0f].CGColor;
     self.imageView.layer.borderWidth = 1.0f;
 }
 

#pragma mark - Setup Method
- (void)setupImageView
{
    // Clip subviews
    self.clipsToBounds = YES;
    
    // Add image subview
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = NO;
    [self addSubview:self.imageView];
    
}

# pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    [self setImageOffset:self.imageOffset];
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    // Store padding value
    _imageOffset = imageOffset;
    NSLog(@"off setting");
    // Grow image view
    CGRect frame = self.imageView.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset.x, _imageOffset.y);
    self.imageView.frame = offsetFrame;
}


@end
