//
//  iBeeperAppDelegate.h
//  iBeeper
//
//  Created by Michael Stemle on 2009.06.17.
//  Copyright Michael D. Stemle, Jr. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeepStorageManager.h"

@class iBeeperViewController;

@interface iBeeperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iBeeperViewController *viewController;
    IBOutlet UINavigationController *navigationController;
    NSData *apsDeviceToken;
}

@property (retain) IBOutlet UIWindow *window;
@property (retain) IBOutlet iBeeperViewController *viewController;

- (void) firstTimeDone;
- (void) makeViewController;
- (void) updateApsStatus;

@end

