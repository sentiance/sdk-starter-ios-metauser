//
//  AppDelegate.m
//  SDKStarterMetaUsers
//
//  Created by David Chelidze on 07/06/2018.
//  Copyright © 2018 Sentiance. All rights reserved.
//

#import "AppDelegate.h"
#import "Definitions.h"
@import SENTSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initializeSentianceSdk:launchOptions];
    return YES;
}

- (void)initializeSentianceSdk {
    [self initializeSentianceSdk:nil];
}

- (void)initializeSentianceSdk:(NSDictionary*) launchOptions {
    
    if([self userIsLoggedIn]) { //Start init process
        
        // Callback method which will be called on linking
        MetaUserLinker metaUserLinker = ^(NSString *installId, void (^linkSuccess)(void), void (^linkFailed)(void)) {
            
            // API call to your backend to ensure linking is successfull
            [self linkUserId:installId thirdPartyId:[self userEmail] completion:^(BOOL success) {
                if(success) {
                    linkSuccess(); // Call on success with linking
                } else {
                    linkFailed();  // Call if something wrong
                }
            }];
            
        };
        
        
        // SDK configuration
        SENTConfig *conf = [[SENTConfig alloc] initWithAppId:APPID
                                                      secret:SECRET
                                                        link:metaUserLinker
                                               launchOptions:launchOptions];
        
        // Initialize and start the Sentiance SDK module
        // The first time an app installs on a device, the SDK requires internet to create a Sentiance platform userid
        [[SENTSDK sharedInstance] initWithConfig:conf success:^{
            // At this point the OS will ask the user to approve the permissions
            [self didAuthenticationSuccess];
            [self startSentianceSdk];
        } failure:^(SENTInitIssue issue) {
            NSLog(@"Failure issue: %lu", (unsigned long)issue);
        }];
    }
}

// Called when the SDK was able to create a platform user
- (void)didAuthenticationSuccess {
    NSLog(@"==== Sentiance SDK started, version: %@",
          [[SENTSDK sharedInstance] getVersion]);
    
    NSLog(@"==== Sentiance platform user id for this install: %@",
          [[SENTSDK sharedInstance] getUserId]);
    
    [[SENTSDK sharedInstance] getUserAccessToken:^(NSString *token) {
        NSLog(@"==== Authorization token that can be used to query the HTTP API: Bearer %@", token);
    } failure:^{
        NSLog(@"Could not retrieve token");
    }];
    
    
    // Notify view controller of successful authentication
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SdkAuthenticationSuccess"
     object:nil];
}

- (void)startSentianceSdk {
    [[SENTSDK sharedInstance] start:^(SENTSDKStatus *status) {
        if ([status startStatus] == SENTStartStatusStarted) {
            NSLog(@"SDK started properly");
        } else if ([status startStatus] == SENTStartStatusPending) {
            NSLog(@"Something prevented the SDK to start properly. Once fixed, the SDK will start automatically");
        }
        else {
            NSLog(@"SDK did not start");
        }
    }];
}

- (BOOL)userIsLoggedIn {
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] valueForKey:USEREMAIL];
    return userEmail.length != 0;
}

- (NSString *)userEmail {
    return [[NSUserDefaults standardUserDefaults] valueForKey:USEREMAIL];
}

#pragma mark - Example of call to validate third party id

- (void)linkUserId:(NSString *)installId thirdPartyId:(NSString *)thirdPartyId completion:(void(^)(BOOL result))completionHanler {
    
    if(installId.length == 0 || thirdPartyId.length == 0) {
        completionHanler(NO);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://example.com/%@", installId]];
    
    NSDictionary *params = @{
                             @"third_party_id" : thirdPartyId
                             };
    
    [self jsonRequestWithUrl:url parameters:params success:^(id responseObject) {
        NSLog(@"RESPONSE:%@", responseObject);
        completionHanler(YES);
        
    } failed:^(NSError *error) {
        NSLog(@"ERROR:%@", [error localizedDescription]);
        completionHanler(NO);
    }];
    
}

- (void)jsonRequestWithUrl:(NSURL *)url parameters:(NSDictionary *)params success:(void (^)(id responseObject))success failed:(void (^)(NSError *error))failure {
    success(@"User Linked");
    //or failed(@"Error request");
}



@end
