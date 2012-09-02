//
//  iBeeperInfoView.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.07.25.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeepStorageManager.h"

@interface iBeeperInfoView : UIViewController {
    IBOutlet UILabel *iBeeperAddressLabel;
    IBOutlet UITextField *userEmail;
    IBOutlet UITextField *userPassword;
    IBOutlet UIButton *saveChangesButton;
    IBOutlet UIButton *forgotButton;
    IBOutlet UILabel *versionIdentity;
}

@property(retain) UILabel *iBeeperAddressLabel;
@property(retain) UITextField *userEmail;
@property(retain) UITextField *userPassword;
@property(retain) UIButton *saveChangesButton;
@property(retain) UIButton *forgotButton;
@property(retain) UILabel *versionIdentity;

- (IBAction) saveChangesClicked:(id)sender;
- (IBAction) forgotPasswordClicked:(id)sender;

@end
