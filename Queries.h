/*
 *  Queries.h
 *  iBeeper
 *
 *  Created by Michael Stemle on 2009.06.24.
 *  Copyright 2009 Michael D. Stemle, Jr.. All rights reserved.
 *
 */

// Get the DB version
#define qGetDbVersionQuery          @"SELECT version FROM db_history ORDER BY version DESC LIMIT 1"

// Get all beep models, sorted in descending order by date.
#define qGetAllBeeps                @"SELECT idnum,subject,sender_email,server_date,message FROM beep_item ORDER BY time_stamp DESC"
#define rsGetAllBeepsIdnum          0
#define rsGetAllBeepsSubject        1
#define rsGetAllBeepsSenderEmail    2
#define rsGetAllBeepsDate           3
#define rsGetAllBeepsMessage        4

// Insert a single beep
#define qInsertBeep                 @"INSERT INTO beep_item(idnum,subject,sender_email,server_date,message) VALUES (?, ?, ?, ?, ?)"
#define rsInsertBeepIdnum           1
#define rsInsertBeepSubject         2
#define rsInsertBeepSenderEmail     3
#define rsInsertBeepServerDate      4
#define rsInsertBeepMessage         5

// Get all idnum values
#define qGetIdnums                  @"SELECT idnum FROM beep_item"

// Get the highest idnum value...
#define qGetMaxIdnum				@"SELECT max(idnum) FROM beep_item"

// Delete a beep
#define qDeleteBeep                 @"DELETE FROM beep_item WHERE idnum=?"
#define rsDeleteBeepIdnum           1
