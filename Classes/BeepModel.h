//
//  BeepModel.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeepModel : NSObject {
    NSInteger idnum;
    NSString *senderEmail;
    NSString *subject;
    NSString *message;
    NSDate *date;
}

@property(assign) NSInteger idnum;
@property(retain) NSString *senderEmail;
@property(retain) NSString *subject;
@property(retain) NSString *message;
@property(retain) NSDate *date;

- (BeepModel*) init;
- (BOOL) saveItem;
- (BOOL) loadItem;
- (NSString*) dateString;
- (NSString*) dateStringForDb;
- (void) setDateString:(NSString*)dateString;

+ (BOOL) deleteItemFromArray:(NSMutableArray**)itemsArray
                   withIndex:(NSInteger)index;

@end
