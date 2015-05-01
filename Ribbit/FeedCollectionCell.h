//
//  FeedCollectionCell.h
//  Ribbit
//
//  Created by Steven on 8/15/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_HEIGHT 150
#define IMAGE_OFFSET_SPEED 25


@interface FeedCollectionCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong, readwrite) UIImage *image;

/*
 Image will always animate according to the imageOffset provided. Higher the value means higher offset for the image
 */

@property (nonatomic, assign, readwrite) CGPoint imageOffset;

@end
