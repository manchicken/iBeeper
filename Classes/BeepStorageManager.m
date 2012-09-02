//
//  BeepRemoteController.m
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.22.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import "BeepStorageManager.h"
#import "JSON/JSON.h"
#import "KeysAndConstants.h"
#import "Queries.h"
#import "SettingsValues.h"
#import "NSStringEmailCategory.h"
#import "AppStateManager.h"
#import "ActionSheetManager.h"

static BeepStorageManager *__remoteStorageInstance = nil;

@implementation BeepStorageManager

@synthesize online;
@synthesize onlineErrorDisplayed;
@synthesize dummyStorage;
@synthesize loading;

#pragma mark Instance Management
+ (BeepStorageManager*)sharedInstance {
	@synchronized(self) {
		if (__remoteStorageInstance == nil) {
			__remoteStorageInstance = [[super allocWithZone:NULL] init];
		}
	}
	
    return __remoteStorageInstance;
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

- (id)init {
    if (self = [super init]) {
        UIDevice *thisDevice = [UIDevice currentDevice];
        deviceId = [thisDevice uniqueIdentifier];
        [deviceId retain];
        newDevice = NO;
        online = NO;
        onlineErrorDisplayed = NO;
		reallyOffline = NO;
    }
    
    return self;
}

#pragma mark Local Beep Storage
- (BOOL) storeBeep:(BeepModel*)beepItem {
    return YES;
}

/*
- (BeepModel*) fetchBeep:(NSInteger)beepId {
    BeepModel *item = [[BeepModel alloc] autorelease];
    NSDate *dateObj = [[NSDate alloc] init];
    item.date = dateObj;
    item.idnum = 0;
    item.senderEmail = @"foo@bar.com";
    item.subject = @"Something bad happened!";
    item.message = @"Something bad happened (from fetchBeep:beepId), you should probably do something about that.";
    
    [dateObj release];
    
    return item;
}
*/

- (NSString*) dbFileString {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent: 
                          [NSString stringWithFormat: @"%@.sqlite", kSqliteDbName] ];
    NSError *poop = nil;
    NSFileManager *fmgr= [NSFileManager defaultManager];
    
    // We need to make sure that we pull over the default plist
    if ([fmgr fileExistsAtPath:filePath] == NO) {
        NSString *sqliteInBundle = [[NSBundle mainBundle] 
                                    pathForResource:kSqliteDbName
                                    ofType:@"sqlite"];
        [fmgr copyItemAtPath:sqliteInBundle
                      toPath:filePath
                       error:&poop];
        if ([poop code] != 0) {
            [self fatalError:[NSString
                              stringWithFormat:@"There was an error copying the database: %@",
                              poop]];
        }
    }
    NSLog(@"Using DB name: %@",filePath);
    
    return filePath;
}

///////// I SHOULD IMPLEMENT THIS TO SAVE TRAFFIC
//- (NSInteger)getYoungestBeepId {
//    sqlite3 *dbconn = (sqlite3*)NULL;
//    sqlite3_stmt *sth = (sqlite3_stmt*)NULL;
//    NSString *errstr = nil;
//    NSString *query = qInsertBeep;
//    NSString *filePath = [self dbFileString];
//    NSInteger storedCount = 0;
//    NSMutableArray *knownIdnums = nil;
//
//	// Now that we got that out of the way, let's open the database.
//    int rc = sqlite3_open_v2([filePath UTF8String],
//                             &dbconn,
//                             SQLITE_OPEN_READWRITE,
//                             NULL);
//	
//    if (rc) {
//        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
//                                    encoding:NSASCIIStringEncoding];
//        NSLog(@"Failed to open database: %@");
//        [self fatalError:[NSString stringWithFormat:@"Failed to open local database: %@",
//                          errstr]];
//    }
//	
//	
//}

- (NSMutableArray*) existingIdnumValues:(sqlite3*)dbconn {
    sqlite3_stmt *sth = (sqlite3_stmt*)NULL;
    NSString *query = qGetIdnums;
    NSMutableArray *toReturn = [[[NSMutableArray alloc] init] autorelease];
    NSString *errstr = nil;
    
    int rc = sqlite3_prepare_v2(dbconn,
                            [query UTF8String],
                            [query length],
                            &sth,
                            NULL);
    if (rc != SQLITE_OK) {
        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                    encoding:NSASCIIStringEncoding];
        sqlite3_close(dbconn);
        [self fatalError:[NSString stringWithFormat:@"Failed to prepare query '%@': %@", query, errstr]];
    }

    while (sqlite3_step(sth) == SQLITE_ROW) {
        [toReturn addObject:[NSNumber numberWithInt:sqlite3_column_int(sth, 0)]];
    }
    
    sqlite3_finalize(sth);
    
    return toReturn;
}

- (NSInteger) storeMultipleBeeps:(NSMutableArray*)beeps {
    sqlite3 *dbconn = (sqlite3*)NULL;
    sqlite3_stmt *sth = (sqlite3_stmt*)NULL;
    NSString *errstr = nil;
    NSString *query = qInsertBeep;
    NSString *filePath = [self dbFileString];
    NSInteger storedCount = 0;
    NSMutableArray *knownIdnums = nil;
    
    // Now that we got that out of the way, let's open the database.
    int rc = sqlite3_open_v2([filePath UTF8String],
                             &dbconn,
                             SQLITE_OPEN_READWRITE,
                             NULL);
    if (rc) {
        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                    encoding:NSASCIIStringEncoding];
        NSLog(@"Failed to open database: %@");
        [self fatalError:[NSString stringWithFormat:@"Failed to open local database: %@",
                          errstr]];
    }
    
    knownIdnums = [self existingIdnumValues:dbconn];
    
    rc = sqlite3_prepare_v2(dbconn,
                            [query UTF8String],
                            [query length],
                            &sth,
                            NULL);
    if (rc != SQLITE_OK) {
        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                    encoding:NSASCIIStringEncoding];
        sqlite3_close(dbconn);
        [self fatalError:[NSString stringWithFormat:@"Failed to prepare query '%@': %@", query, errstr]];
    }
    
    // Step the query
    BeepModel *single = nil;
    NSEnumerator *it = [beeps objectEnumerator];
    NSEnumerator *idnumIt = nil;
    NSNumber *curIdnum = nil;
    BOOL exists = NO;
    while (single = [it nextObject]) {
        idnumIt = [knownIdnums objectEnumerator];
        exists = NO;
        while (curIdnum = [idnumIt nextObject]) {
            if (single.idnum == [curIdnum intValue]) {
                exists = YES;
            }
        }
        
        if (exists == NO) {
            storedCount += 1;
            if (sqlite3_bind_int(sth,
                                 rsInsertBeepIdnum,
                                 single.idnum) != SQLITE_OK) {
                errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                            encoding:NSASCIIStringEncoding];
                sqlite3_close(dbconn);
                [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %@", __LINE__, rsInsertBeepIdnum, query, errstr]];
            }
            if (sqlite3_bind_text(sth,
                                  rsInsertBeepSubject,
                                  [single.subject UTF8String], -1,
                                  SQLITE_TRANSIENT) != SQLITE_OK) {
                errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                            encoding:NSASCIIStringEncoding];
                [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %@", __LINE__, rsInsertBeepSubject, query, errstr]];
            }
            if (sqlite3_bind_text(sth,
                                  rsInsertBeepSenderEmail, 
                                  [single.senderEmail UTF8String], -1,
                                  SQLITE_TRANSIENT) != SQLITE_OK) {
                errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                            encoding:NSASCIIStringEncoding];
                [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %@", __LINE__, rsInsertBeepSenderEmail, query, errstr]];
            }
            if (sqlite3_bind_text(sth,
                                  rsInsertBeepServerDate,
                                  [[single dateStringForDb] UTF8String], -1,
                                  SQLITE_TRANSIENT) != SQLITE_OK) {
                errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                            encoding:NSASCIIStringEncoding];
                [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %@", __LINE__, rsInsertBeepServerDate, query, errstr]];
            }
            if (sqlite3_bind_text(sth,
                                  rsInsertBeepMessage,
                                  [single.message UTF8String], -1,
                                  SQLITE_TRANSIENT) != SQLITE_OK) {
                errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                            encoding:NSASCIIStringEncoding];
                [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %@", __LINE__, rsInsertBeepMessage, query, errstr]];
            }
            rc = sqlite3_step(sth);
            if (rc != SQLITE_ROW && rc != SQLITE_OK && rc != SQLITE_DONE) {
                [self fatalError:[NSString stringWithFormat:@"(%d) Failed to step for query '%@': %s -- Trying to save object: %@", __LINE__, query, sqlite3_errmsg(dbconn), single]];
            }
            
            [knownIdnums addObject:[NSNumber numberWithInt:single.idnum]];
            sqlite3_clear_bindings(sth);
        }
        sqlite3_reset(sth);
    }
    
    sqlite3_finalize(sth);
    sqlite3_close(dbconn);
    
    return storedCount;
}

- (NSMutableArray*) fetchAllBeeps {
//    [self refreshBeepsFromServer:-1];
    
    NSMutableArray *allBeeps = [[[NSMutableArray alloc] init] autorelease];
    sqlite3 *dbconn = (sqlite3*)NULL;
    sqlite3_stmt *sth = (sqlite3_stmt*)NULL;
    NSString *errstr = nil;
    NSString *query = qGetAllBeeps;
    NSString *filePath = [self dbFileString];
    
    // Now that we got that out of the way, let's open the database.
    int rc = sqlite3_open_v2([filePath UTF8String],
                             &dbconn,
                             SQLITE_OPEN_READONLY,
                             NULL);
    if (rc) {
        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                    encoding:NSASCIIStringEncoding];
        NSLog(@"Failed to open database: %@");
        [self fatalError:[NSString
                          stringWithFormat:@"Failed to open local database: %@",
                          errstr]];
    }
    rc = sqlite3_prepare_v2(dbconn,
                            [query UTF8String],
                            [query length],
                            &sth, NULL);
    if (rc != SQLITE_OK) {
        errstr = [NSString stringWithCString:sqlite3_errmsg(dbconn)
                                    encoding:NSASCIIStringEncoding];
		if (FULL_DEBUG) {
			NSLog(@"Failed to prepare query '%@': %@", query, errstr);
		}
        sqlite3_close(dbconn);
        [self fatalError:[NSString stringWithFormat:@"Failed to prepare query '%@': %@", query, errstr]];
    }
    
    // Step the query
    BeepModel *single = nil;
    BOOL skipItem = NO;
    while ((rc = sqlite3_step(sth)) == SQLITE_ROW) {
        // We've got a row, yay!
        single = [[BeepModel alloc] init];
        
        if (!sqlite3_column_int(sth, rsGetAllBeepsIdnum)) {
            NSLog(@"(%d)DIRTY DATABASE! Query: %@",__LINE__,query);
            skipItem = YES;
        } else {
            single.idnum = sqlite3_column_int(sth, rsGetAllBeepsIdnum);
        }
        
        if (!skipItem && sqlite3_column_text(sth, rsGetAllBeepsSubject) != NULL) {
            single.subject = [NSString
                              stringWithUTF8String:(const char*)sqlite3_column_text(sth, rsGetAllBeepsSubject)];
        } else {
            NSLog(@"(%d)DIRTY DATABASE! Query: %@",__LINE__,query);
        }
        
        if (!skipItem && sqlite3_column_text(sth, rsGetAllBeepsSenderEmail) != NULL) {
            single.senderEmail = [NSString
                                  stringWithUTF8String:(const char*)sqlite3_column_text(sth, rsGetAllBeepsSenderEmail)];
        } else {
            NSLog(@"(%d)DIRTY DATABASE! Query: %@",__LINE__,query);
        }

        if (!skipItem && sqlite3_column_text(sth, rsGetAllBeepsDate) != NULL) {
            [single setDateString:[NSString stringWithUTF8String:(const char*)sqlite3_column_text(sth, rsGetAllBeepsDate)]];
        } else {
            NSLog(@"(%d)DIRTY DATABASE! Query: %@",__LINE__,query);
        }

        if (!skipItem && sqlite3_column_text(sth, rsGetAllBeepsMessage) != NULL) {
            single.message = [NSString
                              stringWithUTF8String:(const char*)sqlite3_column_text(sth, rsGetAllBeepsMessage)];
        } else {
            NSLog(@"(%d)DIRTY DATABASE! Query: %@",__LINE__,query);
        }
        
        if (!skipItem) {
            [allBeeps addObject:single];
        }
        [single release];
    }
    
    if (rc != SQLITE_ROW && rc != SQLITE_OK && rc != SQLITE_DONE) {
        [self fatalError:[NSString stringWithFormat:@"(%d) Got a DB error: (%d) %s",
                          __LINE__, rc, sqlite3_errmsg(dbconn)]];
    }
    
    sqlite3_finalize(sth);
    sqlite3_close(dbconn);
    
    return allBeeps;
}

void my_sqlite3_trace_routine(void* arg, const char* message) {
    NSLog(@"Got a trace: %s",message);
    
    return;
}

- (BOOL) deleteLocalBeep:(NSInteger)idnum {
    sqlite3 *dbconn = (sqlite3*)NULL;
    sqlite3_stmt *sth = (sqlite3_stmt*)NULL;
    NSString *query = qDeleteBeep;
    NSString *filePath = [self dbFileString];
    
    NSLog(@"Deleting for beep %d",idnum);
    // Now that we got that out of the way, let's open the database.
    int rc = sqlite3_open_v2([filePath UTF8String],
                             &dbconn,
                             SQLITE_OPEN_READWRITE,
                             NULL);
    if (rc) {
        NSLog(@"Failed to open database: %@");
        [self fatalError:[NSString
                          stringWithFormat:@"(%d)Failed to open local database: %s",
                          __LINE__,sqlite3_errmsg(dbconn)]];
    }
	if (FULL_DEBUG) {
		sqlite3_trace(dbconn, my_sqlite3_trace_routine, NULL);
	}
    rc = sqlite3_prepare_v2(dbconn,
                            [query UTF8String],
                            [query length],
                            &sth, NULL);
    if (rc != SQLITE_OK) {
        NSLog(@"(%d)Failed to prepare query '%@': %@", __LINE__, query,
              sqlite3_errmsg(dbconn));
        sqlite3_close(dbconn);
        [self fatalError:[NSString stringWithFormat:@"(%d)Failed to prepare query '%@': %s", __LINE__, query, sqlite3_errmsg(dbconn)]];
    }
    rc = sqlite3_bind_int(sth, rsDeleteBeepIdnum, idnum);
    if (rc != SQLITE_OK) {
        [self fatalError:[NSString stringWithFormat:@"(%d)Failed to bind key '%d' in query '%@': %d", __LINE__, rsDeleteBeepIdnum, query, sqlite3_errmsg(dbconn)]];
    }
	
	// Handle locks...
    do {
		if (rc == SQLITE_BUSY) {
			sleep(0.2f);
		}
		rc = sqlite3_step(sth);
	} while (rc == SQLITE_BUSY);
		
    if (rc != SQLITE_ROW && rc != SQLITE_OK && rc != SQLITE_DONE) {
        [self fatalError:[NSString stringWithFormat:@"(%d) Failed to step for query '%@': %s", __LINE__, query, sqlite3_errmsg(dbconn)]];
    }
    
    sqlite3_finalize(sth);
    sqlite3_close(dbconn);
    NSLog(@"Done deleting for beep %d: %@",idnum, query);
    
    return YES;
}

#pragma mark Remote Storage
- (BOOL) establishRemoteRelationship {
	AppStateManager *stateManager = [[AppStateManager sharedInstance] retain];
    NSDictionary *fromServer = nil;
	
	if ([[stateManager getAppStat:asEstablished] boolValue] == YES) {
		return YES;
	}
	
	fromServer = [self fetchDataFromRemoteEndpoint:EstablishRemoteRelationship
									withParameters:nil];
    if (fromServer == nil) {
        NSLog(@"(establishRemoteRelationship) Aww, failed to load from server...");
        return NO;
    }
    NSString *result = [fromServer objectForKey:@"result"];
    if ([result compare:@"OK"] == NSOrderedSame) {
		NSLog(@"We're good to go.");
		[stateManager setAppStat:asEstablished withValue:[NSNumber numberWithBool:YES]];
        return YES;
    } else if ([result compare:@"NEW"] == NSOrderedSame) {
        newDevice = YES;
        show_an_alert(@"Welcome to iBeeper", [NSString stringWithFormat:@"Your Alert Email Address is:\n:%@", [self fetchAlertEmailUser]]);
		[stateManager setAppStat:asEstablished withValue:[NSNumber numberWithBool:YES]];

        return YES;
    }
    
    return NO;
}

- (BOOL) refreshBeepsFromServer:(NSInteger)mostRecentBeepId {
    // Fetch our remote data...
    NSDictionary *fromServer = [self
								fetchDataFromRemoteEndpoint:FetchBeeps
											 withParameters:[NSArray arrayWithObject:[NSString
																stringWithFormat:@"beepId=%d",
																mostRecentBeepId]]];

    if (fromServer == nil) {
        return NO;
    }

    NSArray *beepsFromServer = [fromServer objectForKey:kBeeps];
	if (FULL_DEBUG) {
		NSLog(@"Got these beeps: %@",beepsFromServer);
	}
    NSMutableArray *allBeeps = [[[NSMutableArray alloc] init] autorelease];
    
    // Iterate over the results, making objects!
    BeepModel *beep = nil;
    NSEnumerator *iterator = [beepsFromServer objectEnumerator];
    NSDictionary *item = nil;
    
    // Values just for iterating
    BOOL skipItem = NO;
    if (iterator != nil) {
        while (item = [iterator nextObject]) {
			if (FULL_DEBUG) {
				NSLog(@"Got this item: %@",item);
			}
            beep = [[BeepModel alloc] init];
            skipItem = NO;

            // Skip items without idnum values!
            if (!skipItem && ([item valueForKey:kIdnum] == nil)) {
                skipItem = YES;
            } else {
                beep.idnum = [[item valueForKey:kIdnum] intValue];
            }
            
            if (!skipItem && ([item objectForKey:kSubject] != nil)) {
                beep.subject = [[item objectForKey:kSubject] copy];
            }
            
            if (!skipItem && ([item objectForKey:kSenderEmail] != nil)) {
                beep.senderEmail = [[item objectForKey:kSenderEmail] copy];
            }
            
            if (!skipItem && ([item objectForKey:kDate] != nil)) {
                [beep setDateString:[item objectForKey:kDate]];
            }

            if (!skipItem && ([item objectForKey:kMessage] != nil)) {
                beep.message = [[item objectForKey:kMessage] copy];
            }

            if (!skipItem) {
                [allBeeps addObject:beep];
            }
			
			[beep release];
        }
    }
    
    [self storeMultipleBeeps:allBeeps];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    return YES;
}

- (BOOL) deleteRemoteBeep:(NSInteger)beepId {
    NSArray *parameters = [NSArray arrayWithObject:[NSString
                                                    stringWithFormat:
                                                    @"beepId=%d",
                                                    beepId]];
    NSDictionary *fromServer = [self fetchDataFromRemoteEndpoint:DeleteBeep
                                                  withParameters:parameters];
    if (fromServer == nil) {
        NSLog(@"(deleteRemoteBeep) Aww, failed to load from server...");
        return NO;
    }
    NSString *result = [fromServer objectForKey:kResults];
    if ([result compare:@"OK"] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

- (BOOL) sendPasswordReminder {
    NSArray *parameters = [[NSArray alloc] init];
    NSDictionary *fromServer = [self fetchDataFromRemoteEndpoint:SendPasswordReminder
                                                  withParameters:parameters];
    NSString *result = nil;
    
    [parameters release];
    
    if (fromServer == nil) {
        NSLog(@"(sendPasswordReminder) Aww, failed to load from server...");
        return NO;
    }
    
    result = [fromServer objectForKey:kResults];
    if ([result compare:@"OK"] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

- (NSString*) fetchAlertEmailUser {
    NSArray *parameters = [[NSArray alloc] init];
    NSDictionary *fromServer = [self fetchDataFromRemoteEndpoint:FetchAlertEmailUser
                                                  withParameters:parameters];
    NSString *result = nil;
    
    [parameters release];
    
    if (fromServer == nil) {
        NSLog(@"(fetchAlertEmailUser) Aww, failed to load from server...");
        return @"unknown";
    }
    
    result = [fromServer objectForKey:kResults];
    if ([result length] == 0) {
        return @"unknown";
    }
    
    return result;
}

- (BOOL) checkServiceStatus {
    NSArray *parameters = [[NSArray alloc] init];
    NSDictionary *fromServer = [self fetchDataFromRemoteEndpoint:ServiceStatus
                                                  withParameters:parameters];
    [parameters release];
    
    if (fromServer != nil && [(NSString*)[fromServer objectForKey:kResults]
                           compare:@"live"] == NSOrderedSame) {
        online = YES;
    } else {
        if (fromServer == nil) {
            NSLog(@"RESPONSE WAS NIL");
        } else {
            NSLog(@"RESPONSE WAS %@",fromServer);
        }
        
        if (onlineErrorDisplayed == NO) {
            show_an_alert(@"Service Error",
                          @"iBeeper Service is Currently Undergoing Maintenance.");
            onlineErrorDisplayed = YES;
        }
        NSLog(@"SERVICE IS DOWN!");
        online = NO;
		reallyOffline = YES;
    }
    
    return YES;
}

#pragma mark Helpers
- (id) fetchDataFromRemoteEndpoint:(BackendAction)action
                    withParameters:(NSArray*)params {
    // Get our endpoint...
    NSURL *endpoint = [[self getUrlForAction:action
                              withParameters:params] retain];
    
    // Initialize our error object...
    NSError *errorObj = nil;
    
    // This is what we'll return...
    id toReturn = nil;
    
	if (reallyOffline) {
		return nil;
	}
	
    if (action != ServiceStatus && online == NO) {
		if (FULL_DEBUG) {
			NSLog(@"checkServiceStatus is about to be called...");
		}
        [self checkServiceStatus];
    }
    
    if (action != ServiceStatus && self.online == NO) {
        return nil;
    }
    
    // Make the backend request...
    NSLog(@"About to hit URL: %@",endpoint);
    NSString *urlContents = [NSString stringWithContentsOfURL:endpoint
                                                     encoding:NSUTF8StringEncoding
                                                        error:&errorObj];
	if (FULL_DEBUG) {
		NSLog(@"Got back '%@' from backend.",urlContents);
	}
        
    // This is an error condition.
    if (errorObj.code != 0) {
        NSLog(@"Got an error: %@", errorObj);
        show_an_alert(@"Server Fetch Failed",
                      @"Failed to load remote data, please try again later.");
		self.online = NO;
		reallyOffline = YES;

        return nil;
    }
    if (urlContents == nil) {
        show_an_alert(@"Server Fetch Failed",
                      @"Failed to load remote data, please try again later.");
		self.online = NO;
		reallyOffline = YES;

        return nil;
    }
    
    if ([urlContents isEqualToString:reAuthenticationError]) {
        show_an_alert(@"Server Fetch Failed", @"Incorrect Username or Password.");
		self.online = NO;
		reallyOffline = YES;

        return nil;
    }
    
    @try {
        // Let's parse the JSON output...
        SBJSON *jsonParser = [SBJSON new];
        toReturn = [jsonParser objectWithString:urlContents];
        if (toReturn == nil) {
            NSLog(@"Doesn't look like we got a valid JSON string back.");
            show_an_alert(@"Failed to Fetch from Server",
                          [NSString
                           stringWithFormat:@"The server returned an invalid response: %@",
                           urlContents]);
        }
        NSLog(@"Got this in JSON output: %@",toReturn);
    }
    @catch (NSException * e) {
        toReturn = nil;
    }
    @finally {
        [endpoint release];
        if (errorObj != nil) {
            [errorObj release];
        }
    }
    
    return toReturn;
}

- (NSURL*) getUrlForAction:(BackendAction)beAction
            withParameters:(NSArray*)inParams {
    // Check for stuff here...
    NSLog(@"In getUrlForAction...");
    NSUserDefaults *settings = [[NSUserDefaults standardUserDefaults] retain];
    NSString *baseUrl = [[settings stringForKey:cfgServer] retain];
    NSString *action = nil;
    NSMutableArray *params = [[NSMutableArray alloc] initWithArray:inParams];
    
    // Standard params...
    [params addObject:[NSString stringWithFormat:@"deviceId=%@",
                       deviceId]];
    [params addObject:[NSString stringWithFormat:@"emailAddress=%@",
                       [settings stringForKey:cfgEmailAddress]]];
    [params addObject:[NSString stringWithFormat:@"password=%@",
                       [settings stringForKey:cfgPassword]]];
    
    // Set up action and params based on action sent in.
    switch (beAction) {
        case FetchBeeps:
            action = @"fetchBeeps";
            break;
            
        case EstablishRemoteRelationship:
            action = @"establishRemoteRelationship";
            break;
        
        case EnablePushForDevice:
            action = @"enablePushForDevice";
            break;
            
        case DisablePushForDevice:
            action = @"disablePushForDevice";
            break;
        
        case DeleteBeep:
            action = @"deleteBeep";
            break;
            
        case SendPasswordReminder:
            action = @"forgotPassword";
            break;

        case FetchAlertEmailUser:
            action = @"fetchAlertEmailUser";
            break;
        
        case ServiceStatus:
            action = @"serviceStatus";
            break;

        default:
            return nil;
    }
    
    // Now let's make a param string...
    NSMutableString *paramString = [[[NSString stringWithFormat:@"action=%@",
                                     action] mutableCopy] retain];
    // If we have additional params, let's send them...
    if ([params count] > 0) {
        [paramString appendFormat:@"&%@",
         [params componentsJoinedByString:@"&"]];
    }
    NSURL *theUrl = [[[NSURL alloc]
                      initWithString:[NSString
                                      stringWithFormat:@"%@?%@",
                                      baseUrl, paramString]] autorelease];
    [baseUrl release];
    [params release];
    [paramString release];
    [settings release];
    
    NSLog(@"Done with getUrlForAction");
    
    return theUrl;
}

# pragma mark Push Helpers
- (BOOL) setPushStateForDevice:(NSData*)deviceToken
                     withState:(BOOL)enabled {
    NSDictionary *result = nil;
	NSMutableString *myToken = nil;
	NSArray *params = nil;
    BackendAction action = 0;
	AppStateManager *stateManager = [[AppStateManager sharedInstance] retain];

	// Nothing in? Don't bother.
	if (deviceToken == nil) {
		NSLog(@"No device token!");
		return YES;
	}
	
	// Don't redo work...
	if ([stateManager getAppStat:asApsEnabled] != nil &&
		[[stateManager getAppStat:asApsEnabled] boolValue] == enabled)
	{
		NSLog(@"APS STATUS HAS ALREADY BEEN SET!");
		return YES;
	}
	
    NSLog(@"In setPushStateForDevice:withState:");

    myToken = [[NSMutableString alloc] initWithFormat:@"%@",deviceToken];
    [myToken replaceOccurrencesOfString:@" "
                             withString:@"+"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [myToken length])];
    
    params = [NSArray arrayWithObject:[[NSString stringWithFormat:@"deviceToken=%@", deviceToken]
									   stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    if (enabled == YES) {
        action = EnablePushForDevice;
    } else if (enabled == NO) {
        action = DisablePushForDevice;
    } else {
        return NO;
    }
    
    NSLog(@"Got params: %@",params);
    result = [self fetchDataFromRemoteEndpoint:action
                                withParameters:params];
    if (result == nil) {
        return NO;
    }
    
	[stateManager setAppStat:asApsEnabled withValue:[NSNumber numberWithBool:enabled]];
	
    return [[result objectForKey:@"result"] isEqualToString:@"OK"];
}

#pragma mark Network Traffic
- (void) willBeginNetworkTraffic {
	UIApplication *ourApp = [[UIApplication sharedApplication] retain];
	
	ourApp.networkActivityIndicatorVisible = YES;
	
	[ourApp release];
	
	return;
}

- (void) willEndNetworkTraffic {
	UIApplication *ourApp = [[UIApplication sharedApplication] retain];

	ourApp.networkActivityIndicatorVisible = NO;
	
	[ourApp release];
	
	return;
}

- (void)resetOnlineStatus {
	online = YES;
	reallyOffline = NO;
	
	return;
}

#pragma mark Error Handling
- (void) fatalError:(NSString*)message {
    NSLog(@"Fatal Error: %@",message);
    
    exit(-1);
}

void show_an_alert (NSString *title, NSString *message) {
    UIAlertView *aview = [[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] autorelease];
    [aview show];
    
    return;
}
@end
