//
//  SettingsTableViewController.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.23.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "KeysAndConstants.h"
#import "SettingsValues.h"
#import "NSStringEmailCategory.h"
#import "BeepStorageManager.h"

#define FORGOT_BUTTON_SECTION 2

@implementation SettingsTableViewController

@synthesize callBack, target;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // No server?  Reset to hard-coded defaults.
    if ([settings stringForKey:cfgServer] == nil) {
        NSMutableDictionary *hcDefaults = [[NSMutableDictionary alloc] init];
        [hcDefaults setObject:defServer forKey:cfgServer];
        [hcDefaults setObject:defSoundFile forKey:cfgSoundFile];
        [settings registerDefaults:hcDefaults];
        [settings setBool:defEnablePush forKey:cfgEnablePush];
        [settings synchronize];
        
        [hcDefaults release];
    }

    CGRect frame = CGRectMake(kLeftMargin, kTopMargin, kTextFieldWidth, kTextFieldHeight);

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self
                                   action:@selector(doneClicked:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    controls = [[NSMutableArray alloc] init];
    NSMutableArray *sectionOneControls = [[NSMutableArray alloc] init];
    NSMutableArray *sectionTwoControls = [[NSMutableArray alloc] init];
    UITextField *serverField = [[UITextField alloc] initWithFrame:frame];
    UITextField *emailField = [[UITextField alloc] initWithFrame:frame];
    UITextField *passwordField = [[UITextField alloc] initWithFrame:frame];
    
    NSLog(@"I have default server: %@",[settings stringForKey:cfgServer]);

    // Set up the server field
    serverField.placeholder = @"Server Name";
    serverField.secureTextEntry = NO;
    serverField.keyboardType = UIKeyboardTypeURL;
    serverField.clearButtonMode = kClearMode;
    serverField.textColor = kTextColor;
    serverField.borderStyle = kBorderStyle;
    serverField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    serverField.text = [settings stringForKey:cfgServer];
    [sectionOneControls addObject:[NSMutableArray arrayWithObjects:@"Server Name",
                                   serverField,nil]];
    [serverField release];
    
    // Set up the username field
    emailField.placeholder = @"Email Address";
    emailField.secureTextEntry = NO;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    emailField.clearButtonMode = kClearMode;
    emailField.autocorrectionType = UITextAutocorrectionTypeYes;
    emailField.textColor = kTextColor;
    emailField.borderStyle = kBorderStyle;
    emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField.text = [settings stringForKey:cfgEmailAddress];
    [sectionTwoControls addObject:[NSMutableArray arrayWithObjects:@"Email Address",
                                   emailField,nil]];
    [emailField release];

    // Set up the password field
    passwordField.placeholder = @"Password";
    passwordField.secureTextEntry = YES;
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.clearButtonMode = kClearMode;
    passwordField.textColor = kTextColor;
    passwordField.borderStyle = kBorderStyle;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.text = [settings stringForKey:cfgPassword];
    [sectionTwoControls addObject:[NSMutableArray arrayWithObjects:@"Password",
                                   passwordField,nil]];
    [passwordField release];

    // Add the control arrays to the big one
    [controls addObject:sectionOneControls];
    [controls addObject:sectionTwoControls];
    [sectionOneControls release];
    [sectionTwoControls release];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kServerSection:
            return 1;

		case FORGOT_BUTTON_SECTION:
			return 1;
			
        default:
            return 2;
    }
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    @try {
		if (indexPath.section != FORGOT_BUTTON_SECTION) {
			NSMutableArray *section = [controls objectAtIndex:indexPath.section];
			NSLog(@"Section array: %@",section);
			NSMutableArray *row = [section objectAtIndex:indexPath.row];
			NSLog(@"Row array: %@",row);
			NSString *labelText = [row objectAtIndex:kLabelPart];
			UIView *controlItem = [row objectAtIndex:kControlPart];
			// Let's make sure we cache the cell
			if ([row count] == 3) {
				return [row objectAtIndex:kCellPart];
			}
			
			// Still here, must mean we don't have a cell.
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"cachedCell"];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = labelText;
			[cell.contentView addSubview:controlItem];
			[row addObject:cell];
			
			[cell release];
			return [row objectAtIndex:kCellPart];
		} else {

			// Forgot password button...
			if (forgotRow != nil) {
				return forgotRow;
			}
			
			// Must mean we need to create the button...
			forgotRow = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											   reuseIdentifier:@"cachedCell"];
			forgotRow.selectionStyle = UITableViewCellSelectionStyleGray;
			forgotRow.textLabel.text = @"Forgot Password";
			forgotRow.textLabel.textAlignment = UITextAlignmentCenter;
			forgotRow.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
			return forgotRow;
		}
        
    } @catch (NSException *e) {
        NSLog(@"Exception caught: %@",e);
        abort();
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.section == FORGOT_BUTTON_SECTION) {
		// Forgot password, fire callback here...
		NSLog(@"Forgot password clicked...");
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		NSString *email = [[[[controls objectAtIndex:kAccountSection]
							 objectAtIndex:kEmailAddressRow]
							objectAtIndex:kControlPart]
						   text];
		if (email != nil) {
			NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
			[settings setObject:email
						 forKey:cfgEmailAddress];		
			[settings synchronize];
			[settings release];
			[[BeepStorageManager sharedInstance] sendPasswordReminder];
			NSLog(@"Reminder sent.");
		} else {
			NSLog(@"Cannot send reminder, no email address defined yet.");
		}
	}
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [NSArray arrayWithObjects:@"Server", @"User Account", nil];
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [controls release];
	[forgotRow release];
    [super dealloc];
}

#pragma mark IBAction Items
- (IBAction) doneClicked:(id)sender {
    // Validate email
    if ([[[[[controls objectAtIndex:kAccountSection]
       objectAtIndex:kEmailAddressRow]
      objectAtIndex:kControlPart]
          text] isValidEmail] == NO) {
        show_an_alert(@"Invalid Email", @"Please Enter a Valid Email Address.");
        return;
    }
    
    // Okay, let's store the settings...
    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
    [settings setObject:[[[[controls objectAtIndex:kServerSection]
                           objectAtIndex:kServerRow]
                          objectAtIndex:kControlPart]
                         text]
                 forKey:cfgServer];
    [settings setObject:[[[[controls objectAtIndex:kAccountSection]
                           objectAtIndex:kEmailAddressRow]
                          objectAtIndex:kControlPart]
                         text]
                 forKey:cfgEmailAddress];
    [settings setObject:[[[[controls objectAtIndex:kAccountSection]
                           objectAtIndex:kPasswordRow]
                          objectAtIndex:kControlPart]
                         text]
                 forKey:cfgPassword];
    [settings synchronize];
    [settings release];
    
    // We're done here!
    [target performSelector:callBack withObject:nil afterDelay:0];
}

#pragma mark UITextFieldDelegate implementation
- (WhichFieldSelected)determineSelectedField:(UITextField*)textField {
	if (textField == [[[controls objectAtIndex:kServerSection] 
					   objectAtIndex:kServerRow] 
					  objectAtIndex:kControlPart])
	{
		return UITF_server;
	} else if (textField == [[[controls objectAtIndex:kAccountSection] 
							  objectAtIndex:kEmailAddressRow] 
							 objectAtIndex:kControlPart])
	{
		return UITF_email;
	}
	
	return UITF_password;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	WhichFieldSelected selectedField = [self determineSelectedField:textField];

	return YES;
}

@end
