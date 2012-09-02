//
//  BeepModel.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeepModel.h"
#import "BeepStorageManager.h"
#import "KeysAndConstants.h"

#define SERVER_DATE_FORMAT @"MM/dd/yyyy HH:mm:ss zzzz"

@implementation BeepModel

@synthesize idnum,senderEmail,subject,message,date;

- (BeepModel*) init {
    if (self = [super init]) {
        idnum = -1;
        senderEmail = @"Unknown Sender";
        subject = @"Untitled Message";
        message = @"No Message Provided";
        date = [[NSDate alloc] init];
    }
    
    return self;
}

- (BOOL) saveItem {
	NSLog(@"WTF?! No saveItem definition?");
	abort();
    return YES;
}

- (BOOL) loadItem {
	NSLog(@"WTF?! No loadItem definition?");
	abort();
    return YES;
}

- (NSString*) dateString {
    NSDateFormatter *dfmtr = [[NSDateFormatter alloc] init];
    [dfmtr setDateStyle:NSDateFormatterLongStyle];
    [dfmtr setTimeStyle:NSDateFormatterLongStyle];
    NSString *toReturn = [dfmtr stringFromDate:self.date];
    
    [dfmtr release];

    return toReturn;
}

- (NSString*) dateStringForDb {
    NSDateFormatter *dfmtr = [[NSDateFormatter alloc] init];
    
    [dfmtr setDateFormat:SERVER_DATE_FORMAT];
    NSString *toReturn = [dfmtr stringFromDate:self.date];
    
    [dfmtr release];
    
    return toReturn;
}

- (void) setDateString:(NSString*)dateString {
    NSDateFormatter *dfmtr = [[NSDateFormatter alloc] init];
    
    [dfmtr setDateFormat:SERVER_DATE_FORMAT];
    self.date = [dfmtr dateFromString:dateString];
	if (FULL_DEBUG) {
		NSLog(@"setDateString resulted in string: %@ from input %@",date,dateString);
	}
    
    [dfmtr release];
    
    return;
}

#pragma mark Convenient Class Methods
+ (BOOL) deleteItemFromArray:(NSMutableArray**)itemsArray
                   withIndex:(NSInteger)index {

    @try {
//        BeepModel *item = [*itemsArray objectAtIndex:index];
        [*itemsArray removeObjectAtIndex:index];
    }
    @catch (NSException *e) {
        return NO;
    }
    
    return YES;
}

- (void) dealloc {
    
	[subject release];
	[senderEmail release];
	[message release];
	[date release];

	// Dealloc the super
    [super dealloc];
    
    return;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"Idnum: %d; Subject: %@; Sender: %@; Date: %@; Message: %@",
            self.idnum, self.subject, self.senderEmail, [self dateString], self.message];
}

@end
