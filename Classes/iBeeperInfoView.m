//
//  iBeeperInfoView.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.07.25.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import "iBeeperInfoView.h"
#import "SettingsValues.h"
#import "KeysAndConstants.h"
#import "NSStringEmailCategory.h"
#import "AppStateManager.h"

@implementation iBeeperInfoView

@synthesize iBeeperAddressLabel;
@synthesize userEmail;
@synthesize userPassword;
@synthesize saveChangesButton;
@synthesize forgotButton;
@synthesize versionIdentity;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
    NSMutableDictionary *state = nil;
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
	BeepStorageManager *storageProxy = [[BeepStorageManager sharedInstance] retain];
	AppStateManager *appState = [[AppStateManager sharedInstance] retain];
        
    state = [appState fetchAppState];
	[appState release];
    [userEmail setText:(NSString*)[settings stringForKey:cfgEmailAddress]];
    [userPassword setText:[settings stringForKey:cfgPassword]];
    NSLog(@"Got INFO PLIST: %@", infoPlist);
    [versionIdentity setText:[infoPlist objectForKey:@"CFBundleVersion"]];
    
    [iBeeperAddressLabel setText:[storageProxy fetchAlertEmailUser]];
    [settings release];
	
    [storageProxy establishRemoteRelationship];
	[storageProxy willEndNetworkTraffic];
	[storageProxy release];
	
    return;
}

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


- (void)dealloc {
    [super dealloc];
}

#pragma mark UI Actions
- (IBAction) saveChangesClicked:(id)sender {
    // Validate email
    if ([[userEmail text] isValidEmail] == NO) {
        show_an_alert(@"Invalid Email", @"Please enter a valid email.");
        return;
    }
    
    // Okay, let's store the settings...
    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
    [settings setObject:[userEmail text]
                 forKey:cfgEmailAddress];
    [settings setObject:[userPassword text]
                 forKey:cfgPassword];
    [settings synchronize];
    [settings release];
}

- (IBAction) forgotPasswordClicked:(id)sender {
    [[BeepStorageManager sharedInstance] sendPasswordReminder];
}

@end
