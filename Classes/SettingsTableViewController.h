//
//  SettingsTableViewController.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.23.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
	UITF_server = 0,
	UITF_email,
	UITF_password
} WhichFieldSelected;

@interface SettingsTableViewController : UITableViewController
<
	UITableViewDelegate,
	UITableViewDataSource,
	UITextFieldDelegate
>
{
    NSMutableArray *controls;
    SEL callBack;
    id target;
	UITableViewCell *forgotRow;
}

@property(assign) SEL callBack;
@property(assign) id target;

- (IBAction) doneClicked:(id)sender;
- (WhichFieldSelected)determineSelectedField:(UITextField*)textField;

@end
