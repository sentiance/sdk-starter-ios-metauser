//
//  AppDelegate.h
//  SDKStarterMetaUsers
//
//  Created by David Chelidze on 07/06/2018.
//  Copyright © 2018 Sentiance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) initializeSentianceSdk;
- (BOOL)userIsLoggedIn;
- (NSString *)userEmail;

@end

