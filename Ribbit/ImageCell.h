//
//  OrangeCell.h
//  BalancedFlowLayoutDemo
//
//  Created by Niels de Hoog on 29/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRoundedButton.h"


@interface ImageCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet MRHollowBackgroundView *backgroundView;


@end
