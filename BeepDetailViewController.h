//
//  BeepDetailViewController.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.20.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeepModel.h"
#import <MessageUI/MessageUI.h>

@interface BeepDetailViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    // Outlets
    IBOutlet UILabel    *senderEmailLabel;
    IBOutlet UILabel    *subjectLabel;
    IBOutlet UILabel    *dateLabel;
    IBOutlet UITextView *bodyTextView;
    IBOutlet UIToolbar  *toolBarView;
    IBOutlet UIBarButtonItem    *pageNumbers;
    IBOutlet UIScrollView     *wholeView;
	IBOutlet UIView     *contextView;
    
    // Everything else
    NSMutableArray      **beepItems;
    NSUInteger           displayedIndex;
    UIActionSheet       *forwardSheet;
    UIColor *defaultTintColor;
    id mainDisplay;
}

@property(retain) UILabel           *senderEmailLabel;
@property(retain) UILabel           *subjectLabel;
@property(retain) UILabel           *dateLabel;
@property(retain) UITextView        *bodyTextView;
@property(retain) UIToolbar         *toolBarView;
@property(retain) UIBarButtonItem           *pageNumbers;
@property(assign) NSMutableArray    **beepItems;
@property(assign) NSUInteger        displayedIndex;
@property(retain) UIActionSheet     *forwardSheet;
@property(retain) UIScrollView		*wholeView;
@property(retain) UIView			*contextView;
@property(assign) id                mainDisplay;

- (IBAction) deleteBeepItem:(id)sender;
- (IBAction) forwardBeepItem:(id)sender;
- (IBAction) nextPrevBeepItem:(id)sender;
- (IBAction) refreshDisplay:(id)sender;

@end
