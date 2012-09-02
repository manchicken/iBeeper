//
//  iBeeperAppDelegate.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright Michael D. Stemle, Jr. 2009. All rights reserved.
//

#import "iBeeperAppDelegate.h"
#import "iBeeperViewController.h"
#import "SettingsTableViewController.h"
#import "SettingsValues.h"

@implementation iBeeperAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    // Override point for customization after app launch    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
	BeepStorageManager *storageManager = [[BeepStorageManager sharedInstance] retain];
    
    NSLog(@"Email is: %@",[settings stringForKey:cfgEmailAddress]);
    if (([settings stringForKey:cfgPassword] == nil) ||
        ([[settings stringForKey:cfgPassword] length] < 4)) {
        SettingsTableViewController *settingsView = [[SettingsTableViewController alloc]
                                                     initWithNibName:@"SettingsTableViewController" bundle:nil];
        settingsView.callBack = @selector(firstTimeDone);
        settingsView.target = self;
        [navigationController pushViewController:settingsView animated:NO];
        [settingsView release];
    } else {
		[storageManager willBeginNetworkTraffic];

        [self makeViewController];

        [[BeepStorageManager sharedInstance] establishRemoteRelationship];
        [navigationController pushViewController:viewController animated:NO];
        [self updateApsStatus];
		
		[storageManager willEndNetworkTraffic];
    }
    
    NSLog(@"Registering for notifications...");
    [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert|
      UIRemoteNotificationTypeBadge|
      UIRemoteNotificationTypeSound)];
    NSLog(@"Done registering for notifications...");
    [settings release];
	[storageManager release];
}

- (void) makeViewController {
    if (viewController != nil) {
        return;
    }
    
    viewController = [[iBeeperViewController alloc]
                      initWithNibName:@"iBeeperViewController" bundle:nil];
}

- (void) firstTimeDone {
	BeepStorageManager *storageManager = [[BeepStorageManager sharedInstance] retain];
	[storageManager willBeginNetworkTraffic];
    [self makeViewController];
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:viewController animated:YES];

    [[BeepStorageManager sharedInstance] establishRemoteRelationship];
    [self updateApsStatus];
	
	[storageManager willEndNetworkTraffic];
	[storageManager release];
    
    return;
}

- (void) updateApsStatus {
    // Update web service per the user's wishes...
    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
	
	// This check determines whether or not the initial settings have been set...
    if ([[settings stringForKey:cfgPassword] length] > 0) {
        [[BeepStorageManager sharedInstance] setPushStateForDevice:apsDeviceToken
													   withState:[settings boolForKey:cfgEnablePush]];
    }
    
    return;
}

- (void)dealloc {
    [apsDeviceToken release];
    [viewController release];
    [window release];
    [super dealloc];
}

#pragma mark For Push support
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    apsDeviceToken = [deviceToken copy];
    [self updateApsStatus];
    NSLog(@"REGISTERED FOR NOTIFICATIONS WITH SUCCESS: %@",deviceToken);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"!!!!!! Failed to set up notifications: %@",error);
}


@end
