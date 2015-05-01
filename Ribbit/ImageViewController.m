//
//  ImageViewController.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
{
    
    int timeleft;
    NSTimer *timer;
    
    
}

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.navigationController.navigationBarHidden = YES;
   
    self.container.clipsToBounds = YES;
    self.container.layer.cornerRadius = self.container.frame.size.width/2;
    
    self.container.layer.borderColor = [UIColor colorWithRed:70/255.0 green:87/255.0 blue:112/255.0 alpha:1.0].CGColor;
    self.container.layer.borderWidth = .7f;
    

    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
    self.imageView.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;
    
    timeleft = 10;
    
    self.timeLabel.layer.cornerRadius = self.timeLabel.frame.size.width/2;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(timeout)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    }
    else {
        NSLog(@"Error: selector missing!");
    }

}

#pragma mark - Helper methods

- (void)timeout {
    [timer invalidate];
    
     self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)countdown{
    
    self.timeLabel.text = [NSString stringWithFormat:@"%d", timeleft];
    timeleft = timeleft - 1;
    
}

@end
