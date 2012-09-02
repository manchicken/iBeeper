//
//  AppStateManager.h
//  iBeeper
//
//  Created by Michael Stemle on 2010.02.26.
//  Copyright 2010 Michael D. Stemle, Jr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppStateManager : NSObject {
	NSString *appStateFile;
    NSMutableDictionary *appState;
}

+ (AppStateManager*)sharedInstance;

- (NSMutableDictionary*) fetchAppState;
- (BOOL) setAppStat:(NSString*)key withValue:(id)value;
- (id) getAppStat:(NSString*)key;

@end
