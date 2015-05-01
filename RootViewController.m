//
//  RootViewController.m
//  Ribbit
//
//  Created by Steven on 8/3/14.
//  Copyright (c) 2014 Treehouse. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = [NSArray arrayWithObjects:[self.storyboard instantiateViewControllerWithIdentifier:@"feed"], [self.storyboard instantiateViewControllerWithIdentifier:@"inbox"], [self viewControllerWithTabTitle:@"" image:nil], [self.storyboard instantiateViewControllerWithIdentifier:@"friends"], [self.storyboard instantiateViewControllerWithIdentifier:@"camera"] , nil];
    
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"Button_Camera"] highlightImage:[UIImage imageNamed:@"Button_Camera_Highlighted"]];
    
}

-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];

    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(presentView) forControlEvents:UIControlEventTouchUpInside];

    
    button.center = CGPointMake(self.view.center.x, 25);
    [self.tabBar addSubview:button];
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
    
}

@end


