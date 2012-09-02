//
//  AlertDataSource.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertDataSource : NSObject <UITableViewDataSource> {
    NSMutableArray *items;
    NSString *dummy;
}

@property(retain) NSMutableArray *items;

@end
