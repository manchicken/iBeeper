//
//  NSStringEmailCategory.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.11.23.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import "NSStringEmailCategory.h"

@implementation NSString (EmailCategory)

- (BOOL) isValidEmail {
    NSString *pattern = @"[a-zA-Z0-9.-_]+@[a-zA-Z0-9.-_]+\\.[a-zA-Z0-9.-_]{2,4}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",
                         pattern];
    
    return [pred evaluateWithObject:self];
}

@end
