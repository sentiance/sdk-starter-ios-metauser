//
//  ViewController.h
//  SDKStarterMetaUsers
//
//  Created by David Chelidze on 07/06/2018.
//  Copyright © 2018 Sentiance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonInit;

- (IBAction)sdkInitAction:(id)sender;

@end

