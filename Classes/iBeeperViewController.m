//
//  iBeeperViewController.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright Michael D. Stemle, Jr. 2009. All rights reserved.
//

#import "iBeeperViewController.h"
#import "BeepDetailViewController.h"
#import "iBeeperInfoView.h"
#import "BeepStorageManager.h"
#import "KeysAndConstants.h"

@implementation iBeeperViewController

@synthesize beepView;
@synthesize toolBarView;
@synthesize beepItems;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		loading = NO;
		settingItems = NO;
		self.beepItems = nil;
		deletedItems = [[NSMutableArray alloc] init];
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    NSLog(@"Loading view...");
    [super loadView];
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"**** STARTING viewDidLoad ****");
	// Call super...
    [super viewDidLoad];
	
    UIButton *realInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	BeepStorageManager *storageManager = [[BeepStorageManager sharedInstance] retain];
    UINavigationItem *navItem = self.navigationItem;
	UIActivityIndicatorView *activity = nil;

	beepItems = [storageManager fetchAllBeeps];
	[beepItems retain];
	
	// Set up navigation stuff...
    [navItem setTitle:@"Pages"];
    editButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                  target:self
                  action:@selector(enterPagesEditMode:)];
    doneButton = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                  target:self
                  action:@selector(enterPagesEditMode:)];
    [navItem setRightBarButtonItem:editButton animated:NO];
    
    // Set up the toolbar
    [realInfoButton addTarget:self
                       action:@selector(displayInfo:)
             forControlEvents:UIControlEventTouchDown];
    infoButton = [[UIBarButtonItem alloc] initWithCustomView:realInfoButton];
    refreshButton = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                     target:self
                     action:@selector(refreshDisplay:)];
    toolbarSpacer = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                     target:nil action:nil];
    [self.toolBarView setItems:[NSArray arrayWithObjects:
								refreshButton,
								toolbarSpacer,
								infoButton,
								nil]
					  animated:NO];

	activity = [[UIActivityIndicatorView alloc]
				initWithFrame:CGRectMake(0, 0, 18, 18)];
	[activity startAnimating];
	loadingButton = [[UIBarButtonItem alloc]
					 initWithCustomView:activity];
	[activity release];
	
	// Clean up from storage manager
	[storageManager release];
	NSLog(@"**** DONE WITH viewDidLoad ****");

	[self refreshDisplay:self];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.beepView = nil;
	self.toolBarView = nil;
}


- (void)dealloc {
	[deletedItems release];
	[beepItems release];
    [editButton release];
    [doneButton release];
    [infoButton release];
    [refreshButton release];
	[loadingButton release];
    [toolbarSpacer release];
    [super dealloc];
}

#pragma mark UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (FULL_DEBUG) {
		NSLog(@"Getting sections in table");
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if (FULL_DEBUG) {
		NSLog(@"Getting rows in section");
	}
    return [beepItems count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Now let's see what we can do to keep from crashing during a load...
	while (settingItems) {
		sleep(0.2f);
	}
	
	if (FULL_DEBUG) {
		NSLog(@"Getting a table cell...");
	}
    static NSString *MyIdentifier = @"BeepItemCell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:MyIdentifier] autorelease];
    }

    // Set data
    BeepModel *item = nil;
    @try {
        item = [self.beepItems objectAtIndex:indexPath.row];
    }
    @catch (NSException * e) {
        NSLog(@"NO ITEMS!!!!");
        return nil;
    }
    cell.textLabel.text = [item subject];
    cell.detailTextLabel.text = [item dateString];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // Set accessories and such
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setEditingAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([beepItems objectAtIndex:indexPath.row] != nil) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // No items? Do nothing.
    if (beepItems == nil) {
        return;
    }
	
	[self triggerDelete:indexPath];
    
    return;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (FULL_DEBUG) {
		NSLog(@"TAPPED!!!!!!");
	}
    BeepModel *item = nil;
    
    @try {
        item = [beepItems objectAtIndex:indexPath.row];
        [item retain];
    } @catch (NSException *e) {
        NSLog(@"Caught exception: %@",e);
        return;
    }
    
    [[self.beepView cellForRowAtIndexPath:indexPath] setSelected:NO];
    BeepDetailViewController *detailViewController = [[BeepDetailViewController alloc]
                                                     initWithNibName:@"BeepDetailViewController"
                                                            bundle:nil];
    [detailViewController setBeepItems:&beepItems];
    [detailViewController setMainDisplay:self];
    [detailViewController setDisplayedIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    [item release];
    
    return;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    // Is this me?
    if ([viewController isKindOfClass:[iBeeperViewController class]]) {
        [self refreshDisplay:nil];
    }
    
    return;
}

#pragma mark Custom Actions
- (IBAction) refreshDisplay:(id)sender {
	if (loading) {
		return;
	}
	
    [self.toolBarView setItems:[NSArray arrayWithObjects:
								loadingButton,
								toolbarSpacer,
								infoButton,
								nil]
					  animated:NO];
	
	loading = YES;
	
	[NSThread detachNewThreadSelector:@selector(refreshBeeps:)
							 toTarget:self withObject:self.beepItems];
}

- (void)refreshBeeps:(NSMutableArray*)existingItems {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[existingItems retain];
	
	NSMutableArray *items = nil;
    // Get the latest idnum we have
    NSInteger latestIdNum = -1;
	BeepStorageManager *storageManager = [[BeepStorageManager sharedInstance] retain];
    if (existingItems != nil && [existingItems count] > 0) {
        latestIdNum = [[existingItems objectAtIndex:0] idnum];
    }
	
	[storageManager resetOnlineStatus];
    
	[storageManager willBeginNetworkTraffic];
    [storageManager setOnlineErrorDisplayed:NO];
	[storageManager refreshBeepsFromServer:-1];
    items = [[storageManager fetchAllBeeps] retain];
	[storageManager willEndNetworkTraffic];
	[storageManager release];
	
	[self performSelectorOnMainThread:@selector(updateDisplayedBeeps:)
						   withObject:items
						waitUntilDone:NO];
	[items release];
	
	[pool release];
	
	return;
}

- (void) updateDisplayedBeeps:(NSMutableArray*)items {
	NSLog(@"REFRESHING DISPLAY NOW...");
	
	[items retain];
	
	// Apply refreshed data to the view
	BeepStorageManager *storageManager = [[BeepStorageManager sharedInstance] retain];
	settingItems = YES;
	self.beepItems = items;
	
	id killMe = nil;
	if ([deletedItems count] > 0) {
		for (killMe in deletedItems) {
			[beepItems removeObjectAtIndex:[killMe integerValue]];
			[deletedItems removeObject:killMe];
		}
	}
	
	settingItems = NO;
	[self.beepView reloadData];
	[storageManager release];
	[items release];
	
	loading = NO;
    [self.toolBarView setItems:[NSArray arrayWithObjects:
								refreshButton,
								toolbarSpacer,
								infoButton,
								nil]
					  animated:NO];
	
    return;
}

- (IBAction) displayInfo:(id)sender {
	if (FULL_DEBUG) {
		NSLog(@"displayInfo: called.");
	}
	[[BeepStorageManager sharedInstance] willBeginNetworkTraffic];
    BeepDetailViewController *infoViewController = [[iBeeperInfoView alloc]
                                                      initWithNibName:@"iBeeperInfoView"
                                                      bundle:nil];
    [self.navigationController pushViewController:infoViewController animated:YES];
    [infoViewController release];

    return;
}

- (IBAction) enterPagesEditMode:(id)sender {
    if ([beepView isEditing]) {
        [beepView setEditing:NO
                    animated:YES];
        self.navigationItem.rightBarButtonItem = editButton;
    } else {
        [beepView setEditing:YES
                       animated:YES];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    return;
}

#pragma mark Helpers
- (void) deleteBeepItem:(NSNumber*)idnum {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	BeepStorageManager *storageProxy = [BeepStorageManager sharedInstance];
	[storageProxy deleteRemoteBeep:[idnum integerValue]];

	[pool release];
}

- (void)triggerDelete:(NSIndexPath*)indexPath {
	int idnum = -1;
	
	if (loading) {
		[deletedItems addObject:[NSNumber numberWithInt:indexPath.row]];
	}	
	
	idnum = [[beepItems objectAtIndex:indexPath.row] idnum];
	
    [BeepModel deleteItemFromArray:&beepItems
						 withIndex:indexPath.row];
	BeepStorageManager *storageProxy = [BeepStorageManager sharedInstance];
	[storageProxy deleteLocalBeep:idnum];

	[NSThread detachNewThreadSelector:@selector(deleteBeepItem:)
							 toTarget:self withObject:[NSNumber numberWithInt:idnum]];
	
	[self.beepView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
						 withRowAnimation:UITableViewRowAnimationRight];
	
	return;
}

@end
