//
//  AppDelegate.m
//  Ribbit
//
//  Copyright (c) 2013 Treehouse. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MRoundedButton.h"




@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [Parse setApplicationId:@"1RErO9sHGrVSmd9fvbEG0BRUiTyyQTg9AIeQGvkf"
                  clientKey:@"shBtikHcMWrdUl8jc5Ux3oN4G6PiRNFcqLfPg3QW"];
    
    [PFFacebookUtils initializeFacebook];
    [self customizeUserInterface];
    
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helper methods

- (void)customizeUserInterface {
    /*** NAV BAR ***/
    
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:252/255.0 green:90/255.0 blue:106/255.0 alpha:1.0]];
//  [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarBackground"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:39/255.0 green:39/255.0 blue:39/255.0 alpha:1.0f], UITextAttributeTextColor, nil]];
   // [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0f]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0f]];
    
    NSDictionary *appearanceProxy1 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @2,
                                       kMRoundedButtonBorderColor  : [UIColor clearColor],
                                       kMRoundedButtonContentColor : [UIColor blackColor],
                                       kMRoundedButtonContentAnimationColor : [UIColor whiteColor],
                                       kMRoundedButtonForegroundColor : [UIColor whiteColor],
                                       kMRoundedButtonForegroundAnimationColor : [UIColor clearColor]};
    
    NSDictionary *appearanceProxy2 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @1,
                                       kMRoundedButtonRestoreHighlightState : @YES,
                                       kMRoundedButtonBorderColor : [[UIColor whiteColor] colorWithAlphaComponent:.5 ],
                                       kMRoundedButtonBorderAnimationColor : [UIColor whiteColor],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimationColor : [UIColor colorWithRed:252/255.0 green:90/255.0 blue:106/255.0 alpha:1.0],
                                       kMRoundedButtonForegroundColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundAnimationColor : [UIColor whiteColor]};
    
    NSDictionary *appearanceProxy3 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @1,
                                       kMRoundedButtonRestoreHighlightState : @NO,
                                       kMRoundedButtonBorderColor : [[UIColor whiteColor] colorWithAlphaComponent:.5 ],
                                       kMRoundedButtonBorderAnimationColor : [UIColor whiteColor],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimationColor : [UIColor colorWithRed:252/255.0 green:90/255.0 blue:106/255.0 alpha:1.0],
                                       kMRoundedButtonForegroundColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundAnimationColor : [UIColor whiteColor]};
    
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy1 forIdentifier:@"1"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy2 forIdentifier:@"2"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy3 forIdentifier:@"3"];


    /***    TAB BAR     ***/
   // [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]  ];
    

    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"TabBG"] ];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"Tab_Selected"]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0f]];

}

@end









