//
//  ActionSheetDelegate.m
//  iBeeper
//
//  Created by Michael Stemle on 2010.02.24.
//  Copyright 2010 Michael D. Stemle, Jr. All rights reserved.
//

#import "ActionSheetManager.h"


@implementation ActionSheetManager

+ (UIActionSheet*)alertUserWithActionSheet:(NSString*)message {
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:message
													   delegate:self
											  cancelButtonTitle:@"OK"
										 destructiveButtonTitle:nil
											  otherButtonTitles:nil];
	
//	sheet.actionSheetStyle = UIBarStyleBlackTranslucent;
	
	return [sheet autorelease];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	return;
}

@end
