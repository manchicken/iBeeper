/*
 *  KeysAndConstants.h
 *  iBeeper
 *
 *  Created by Michael Stemle on 2009.06.24.
 *  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
 *
 */

#define FULL_DEBUG			NO

// Settings stuff
#define MIN_DETAIL_VIEW_HEIGHT 273

// Settings table stuff
#define kTextFieldWidth     162.0
#define kLeftMargin         135.0
#define kTopMargin          12.0
#define kRightMargin        20.0
#define kTextFieldHeight    30.0
#define kTextColor          [[[UIColor alloc] initWithRed:0.25 green:0.25 blue:1 alpha:0.65] autorelease]
#define kClearMode          UITextFieldViewModeWhileEditing
#define kBorderStyle        UITextBorderStyleNone
#define kServerSection      0
#define kServerRow          0
#define kAccountSection     1
#define kEmailAddressRow    0
#define kPasswordRow        1
#define kLabelPart          0
#define kControlPart        1
#define kCellPart           2

// AppStat stuff
#define kAppStatPlist       @"appStat"

// SQLite stuff
#define kSqliteDbName       @"iBeeper"
#define kLatestDbVersion    1.0

// Server data keys and such
#define kBeeps              @"beeps"
#define kResults            @"result"
#define kIdnum              @"idnum"
#define kSubject            @"subject"
#define kSenderEmail        @"sender_email"
#define kDate               @"server_date"
#define kMessage            @"message"

// Some remote error tokens
#define reAuthenticationError   @"AUTHENTICATION ERROR"

// AppState Keys
#define asApsEnabled		@"APS_STATE"
#define asEstablished		@"RELATIONSHIP_ESTABLISHED"
