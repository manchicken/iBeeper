//
//  ActionSheetDelegate.h
//  iBeeper
//
//  Created by Michael Stemle on 2010.02.24.
//  Copyright 2010 Michael D. Stemle, Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ActionSheetManager : NSObject <UIActionSheetDelegate> {

}

+ (UIActionSheet*)alertUserWithActionSheet:(NSString*)message;

@end
