//
//  iBeeperViewController.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright Michael D. Stemle, Jr. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BeepModel.h"

@interface iBeeperViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate> {
    IBOutlet UITableView        *beepView;
    IBOutlet UIToolbar          *toolBarView;

    NSMutableArray              *beepItems;
    UIBarButtonItem             *editButton;
    UIBarButtonItem             *doneButton;
    UIBarButtonItem             *infoButton;
    UIBarButtonItem             *toolbarSpacer;
    UIBarButtonItem             *refreshButton;
	UIBarButtonItem				*loadingButton;
	NSMutableArray				*deletedItems;
	
	BOOL loading;
	BOOL settingItems;
}

@property(retain) UITableView       *beepView;
@property(retain) UIToolbar         *toolBarView;
@property(retain) NSMutableArray    *beepItems;

- (IBAction) refreshDisplay:(id)sender;
- (void) updateDisplayedBeeps:(NSMutableArray*)items;
- (IBAction) displayInfo:(id)sender;
- (IBAction) enterPagesEditMode:(id)sender;
- (void)triggerDelete:(NSIndexPath*)indexPath;
- (void) deleteBeepItem:(NSNumber*)idnum;
- (void)refreshBeeps:(NSMutableArray*)existingItems;

@end

