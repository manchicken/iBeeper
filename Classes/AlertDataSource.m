//
//  AlertDataSource.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import "AlertDataSource.h"

#define CELL_NAME @"AlertDataSourceCell"

@implementation AlertDataSource

@synthesize items;

- (AlertDataSource*) init {
    NSLog(@"init was called!!!!!!!");
    if (self = [super init]) {
        items = nil;
        dummy = [[NSString alloc] initWithString:@"FOO!!!"];
    }
    
    return self;
}

- (UITableViewCell*) tableView:(UITableView*)tableView
         cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"HERE!!!!!!!!!!!!!!!!!!!");
    static NSString *cellName = CELL_NAME;
    
    NSLog(@"I got tableView: %p", tableView);
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellName];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellName]
                autorelease];
    }
    
    cell.textLabel.text = dummy;
    
    return cell;
}

//- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
//    return 1;
//}

- (NSInteger) tableView:(UITableView*)tableView
  numberOfRowsInSection:(NSInteger)section {
    return 2;
}

/*
 To conform to Human Interface Guildelines, since selecting a row would have no effect (such as navigation), make sure that rows cannot be selected.
 */
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}

//- (NSArray*) sectionIndexTitlesForTableView:(UITableView*)tableView {
//    return nil;
//}

- (void) dealloc {
    [dummy release];
    [super dealloc];
}

@end
