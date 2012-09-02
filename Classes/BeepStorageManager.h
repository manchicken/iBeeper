//
//  BeepStorageDelegate.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.22.
//  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "BeepModel.h"

@interface BeepStorageManager : NSObject {
    NSString *deviceId;
    NSString *email;
    NSString *password;
    BOOL online;
	BOOL reallyOffline;
    BOOL onlineErrorDisplayed;
    BOOL newDevice;
	BOOL loading;
    NSMutableArray *dummyStorage;
}

typedef enum {
    FetchBeeps,
    EstablishRemoteRelationship,
    EnablePushForDevice,
    DisablePushForDevice,
    DeleteBeep,
    SendPasswordReminder,
    FetchAlertEmailUser,
    ServiceStatus
} BackendAction;

@property(assign,getter=isOnline) BOOL online;
@property(assign,setter=setOnlineErrorDisplayed,getter=isOnlineErrorDisplayed) BOOL onlineErrorDisplayed;
@property(retain) NSMutableArray *dummyStorage;
@property(assign,getter=isLoading) BOOL loading;

+ (BeepStorageManager*)sharedInstance;

- (BOOL) storeBeep:(id)beepItem;
- (NSString*) dbFileString;
- (NSMutableArray*) existingIdnumValues:(sqlite3*)dbconn;
- (NSInteger) storeMultipleBeeps:(NSMutableArray*)beeps;
- (NSMutableArray*) fetchAllBeeps;
- (BOOL) deleteLocalBeep:(NSInteger)idnum;
- (BOOL) establishRemoteRelationship;
- (BOOL) refreshBeepsFromServer:(NSInteger)mostRecentBeepId;
- (BOOL) deleteRemoteBeep:(NSInteger)beepId;
- (BOOL) sendPasswordReminder;
- (NSString*) fetchAlertEmailUser;
- (BOOL) checkServiceStatus;
- (id) fetchDataFromRemoteEndpoint:(BackendAction)action
                    withParameters:(NSArray*)params;
- (NSURL*) getUrlForAction:(BackendAction)action
            withParameters:(NSArray*)inParams;
- (BOOL) setPushStateForDevice:(NSData*)deviceToken
                     withState:(BOOL)enabled;
- (void) fatalError:(NSString*)title;

// Network Traffic Routines
- (void) willBeginNetworkTraffic;
- (void) willEndNetworkTraffic;
- (void)resetOnlineStatus;
//- (void)asyncBeep

#pragma mark C Routines
void show_an_alert (NSString *title, NSString *message);
void my_sqlite3_trace_routine(void* arg, const char* message);
@end
