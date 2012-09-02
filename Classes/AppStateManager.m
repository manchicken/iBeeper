//
//  AppStateManager.m
//  iBeeper
//
//  Created by Michael Stemle on 2010.02.26.
//  Copyright 2010 Michael D. Stemle, Jr. All rights reserved.
//

#import "AppStateManager.h"
#import "KeysAndConstants.h"

static AppStateManager *__appStateInstance = nil;

@implementation AppStateManager

+ (AppStateManager*)sharedInstance {
	@synchronized(self) {
		if (__appStateInstance == nil) {
			__appStateInstance = [[super allocWithZone:NULL] init];
			[__appStateInstance fetchAppState];
		}		
	}
	
	return __appStateInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (AppStateManager*)init {
	if (self = [super init]) {
		appState = nil;
	}
	
	return self;
}

#pragma mark Business Routines
- (NSMutableDictionary*) fetchAppState {
	if (appState != nil) {
		return appState;
	}
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *filePath = [[docPath stringByAppendingPathComponent: 
						  [NSString stringWithFormat: @"%@.plist", kAppStatPlist]]
						  retain];
    
    NSError *poop = nil;
    
    NSFileManager *fmgr= [NSFileManager defaultManager];
    
    // We need to make sure that we pull over the default plist
    if ([fmgr fileExistsAtPath:filePath] == NO) {
        NSString *plistInBundle = [[NSBundle mainBundle] 
                                   pathForResource:kAppStatPlist
                                   ofType:@"plist"];
        [fmgr copyItemAtPath:plistInBundle
                      toPath:filePath
                       error:&poop];
        if ([poop code] != 0) {
            NSLog(@"There was an error copying the app state: %@", poop);
			abort();
        }
    }
    
    appStateFile = filePath;
    [appStateFile retain];
    [filePath release];
    
    appState = [[NSMutableDictionary dictionaryWithContentsOfFile:appStateFile] retain];
	
	return appState;
}

- (BOOL) setAppStat:(NSString*)key withValue:(id)value {
	NSLog(@"Setting App State!!!");
    [appState setObject:value forKey:key];
    [appState writeToFile:appStateFile atomically:YES];
	NSLog(@"DONE Setting App State!!!");
    
    return YES;
}

- (id)getAppStat:(NSString *)key {
	return [appState objectForKey:key];
}

@end
