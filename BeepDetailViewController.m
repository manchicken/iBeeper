//
//  BeepDetailViewController.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.20.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

/**** REQUIRED HEADER FROM APPLE FOR SEGMENTED CONTROL CODE ****
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#import "BeepDetailViewController.h"
#import "iBeeperViewController.h"
#import "KeysAndConstants.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIStringDrawing.h>

@implementation BeepDetailViewController

@synthesize senderEmailLabel;
@synthesize subjectLabel;
@synthesize dateLabel;
@synthesize bodyTextView;
@synthesize toolBarView;
@synthesize pageNumbers;
@synthesize beepItems;
@synthesize displayedIndex;
@synthesize forwardSheet;
@synthesize mainDisplay;
@synthesize wholeView;
@synthesize contextView;

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
    NSLog(@"BeepDetailViewController DID LOAD!!!!");

//	wholeView.contentSize 
//	contextView.contentStretch 
//	float wholewidth = bodyTextView.frame.size.width;
//	NSString *myStr = [bodyTextView.text retain];
//	CGSize textViewSize = [bodyTextView.text sizeWithFont:bodyTextView.font
//										constrainedToSize:CGSizeMake(wholewidth, 2000.0f)
//											lineBreakMode:UILineBreakModeCharacterWrap];
//	[myStr release];
//	float wholeheight = 80.0f + textViewSize.height;
////	wholeView.contentSize = CGSizeMake(wholewidth, wholeheight);
////	NSLog(@"Size should be: %0.2fx%0.2f", wholewidth, wholeheight);
////	NSLog(@"Whole size is: %0.2fx%0.2f",wholeView.contentSize.width, wholeView.contentSize.height);
//
//	wholeView.contentSize = CGSizeMake(bodyTextView.contentSize.width, wholeheight);
	
    [super viewDidLoad];
    [self refreshDisplay:nil];

    return;
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
	self.senderEmailLabel = nil;
	self.subjectLabel = nil;
	self.dateLabel = nil;
	self.bodyTextView = nil;
	self.toolBarView = nil;
	self.pageNumbers = nil;
	self.wholeView = nil;
	self.contextView = nil;
}

- (void)dealloc {
	[forwardSheet release];
    [super dealloc];
}

#pragma mark Custom Actions
/* Actions */
- (IBAction) deleteBeepItem:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath
                              indexPathForRow:displayedIndex
                              inSection:0];
    iBeeperViewController *vc = self.mainDisplay;
//    [vc deleteBeepItem:indexPath];
	[vc triggerDelete:indexPath];

    if ([*beepItems count] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (displayedIndex == [*beepItems count]) {
            displayedIndex -= 1;
        }
//        
        [self refreshDisplay:nil];
    }
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [wholeView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
    
    return;
}

- (IBAction) forwardBeepItem:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    if (forwardSheet == nil) {
        forwardSheet = [[UIActionSheet alloc]
                        initWithTitle:@"Forward"
                        delegate:self cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Forward",nil];
    }
    [forwardSheet showFromToolbar:self.toolBarView];
    
    return;
}

- (IBAction) refreshDisplay:(id)sender {
    BeepModel *theItem = nil;
    @try {
        theItem = [*beepItems objectAtIndex:displayedIndex];
    }
    @catch (NSException * e) {
        NSLog(@"Caught exception trying to fetch item index '%d'. I count %d items in the array.",
              displayedIndex, [*beepItems count]);
        return;
    }
    
    // Nav items
    UINavigationItem *navItem = self.navigationItem;

    // Get pages
    NSString *pageNumberText = [[NSString stringWithFormat:@"%d of %d",
                                (displayedIndex+1), [*beepItems count]] retain];
    
    // Segmented control (THANKS APPLE!!!)
    // "Segmented" control to the right
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"up.png"],
                                             [UIImage imageNamed:@"down.png"],
                                             nil]];
	[segmentedControl addTarget:self
                         action:@selector(nextPrevBeepItem:)
               forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30.0);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
    
    if (displayedIndex == 0) {
        [segmentedControl setEnabled:NO
                   forSegmentAtIndex:0];
    }
    
    if (displayedIndex == ([*beepItems count]-1)) {
        [segmentedControl setEnabled:NO
                   forSegmentAtIndex:1];
    }
	
	defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
    
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
	navItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];    
    
    [navItem setTitle:[theItem subject]];
    
    // Data view
    [senderEmailLabel setText:[theItem senderEmail]];
    [subjectLabel setText:[theItem subject]];
    [dateLabel setText:[theItem dateString]];
    [bodyTextView setText:[theItem message]];
	pageNumbers.title = pageNumberText;

	CGSize textViewSize = [bodyTextView.text sizeWithFont:bodyTextView.font
										constrainedToSize:CGSizeMake(contextView.frame.size.width,
																	 10000.0f)
											lineBreakMode:UILineBreakModeCharacterWrap];
	// Make sure we don't shrink horizontally...
	textViewSize.width = contextView.frame.size.width;
	
	// Make sure we have a height that will still bounce even when the message is smaller.
	if (textViewSize.height < MIN_DETAIL_VIEW_HEIGHT) {
		textViewSize.height = MIN_DETAIL_VIEW_HEIGHT;
	}
	
	wholeView.contentSize = CGSizeMake(bodyTextView.contentSize.width,
									   80.0f+20.0f+textViewSize.height);
	contextView.frame = CGRectMake(0.0f,0.0f,textViewSize.width,textViewSize.height+80.0f+20.0f);
	
    // Cleanup
    [pageNumberText release];
    [defaultTintColor release];
    
    return;
}

#pragma mark UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.forwardSheet dismissWithClickedButtonIndex:buttonIndex
     animated:YES];
    
    BeepModel *theItem = [*beepItems objectAtIndex:displayedIndex];
    
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc]
                                             init];
    mailView.mailComposeDelegate = self;
//    mailView.navigationBar.barStyle = UIBarStyleBlack;
    
    [mailView setSubject:theItem.subject];
    [mailView setMessageBody:[theItem description] isHTML:NO];
    [self presentModalViewController:mailView animated:YES];
    [mailView release];
    
    return;
}

#pragma mark MFMailComposeViewControllerDelegate
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UISegmentedControl
- (IBAction) nextPrevBeepItem:(id)sender {
    UISegmentedControl *segmentedControl = sender;
    NSString *direction = nil;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        // Previous
        NSLog(@"Moving to the PREVIOUS one...");
        if (displayedIndex == 0) {
            NSLog(@"Tried to go back before zero...");
            return;
        }
        
        direction = kCATransitionFromBottom;
        
        // Set the display index
        displayedIndex -= 1;
    } else {
        // Next
        NSLog(@"Moving to the NEXT one...");
        if (displayedIndex == ([*beepItems count]-1)) {
            NSLog(@"Tried to go past last item...");
            return;
        }
        
        direction = kCATransitionFromTop;
        
        // Set the display index
        displayedIndex += 1;
    }
    
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionMoveIn;
    animation.subtype = direction;
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [wholeView.layer addAnimation:animation forKey:@"transitionViewAnimation"];    

    [self refreshDisplay:nil];
    
    return;
}

@end
