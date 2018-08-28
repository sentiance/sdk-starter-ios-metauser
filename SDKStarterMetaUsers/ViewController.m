//
//  ViewController.m
//  SDKStarterMetaUsers
//
//  Created by David Chelidze on 07/06/2018.
//  Copyright © 2018 Sentiance. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Definitions.h"

@import SENTSDK;

@interface ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Our AppDelegate broadcasts when sdk auth was successful
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStatus)
                                                 name:@"SdkAuthenticationSuccess"
                                               object:nil];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    self.inputEmail.delegate = self;
    
    
    if([self.appDelegate userIsLoggedIn]) {
        [self hideLogin];
    } else {
        [self showLogin];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshStatus];
}

- (void)refreshStatus {
    // Make sure the SDK is initialized or an exception will be thrown.
    if ([[SENTSDK sharedInstance] isInitialised]) {
        self.userIdLabel.text = [[SENTSDK sharedInstance] getUserId];
        // You can use the status message for more information
        SENTSDKStatus* status = [[SENTSDK sharedInstance] getSdkStatus];
    }
}

- (IBAction)sdkInitAction:(id)sender {
    [self trimEmail];
    if(![self isValidEmail:self.inputEmail.text]) {
        [self showInvalidEmailAlert];
        return;
    }
    
    //We are logged in
    [[NSUserDefaults standardUserDefaults] setValue:self.inputEmail.text forKey:USEREMAIL];
    [self.appDelegate initializeSentianceSdk];
    [self hideLogin];
}

- (void)hideLogin {
    [self.userIdLabel setHidden:NO];
    [self.userEmailLabel setHidden:NO];
    [self.inputEmail setHidden:YES];
    [self.buttonInit setHidden:YES];
    [self.inputEmail resignFirstResponder];
    self.userEmailLabel.text = [self.appDelegate userEmail];
}

- (void)showLogin {
    [self.userIdLabel setHidden:YES];
    [self.userEmailLabel setHidden:YES];
    [self.inputEmail setHidden:NO];
    [self.buttonInit setHidden:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self trimEmail];
    [textField resignFirstResponder];
    return YES;
}

- (void)trimEmail {
    //Keyboard email suggest autofill adds space at the end
    NSString *emailString = self.inputEmail.text;
    NSString *trimmed = [emailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.inputEmail.text = trimmed;
}


- (BOOL)isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)showInvalidEmailAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter valid email address" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.inputEmail becomeFirstResponder];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:^{}];
}

@end
