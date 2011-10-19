//
//  PreferencesController.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/06.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Settings.h"

#import <RestKit/RestKit.h>

#define kPreferencesBasecampDomain 0
#define kPreferencesBasecampUsername 1
#define kPreferencesBasecampPassword 2

@interface PreferencesController : NSWindowController <NSWindowDelegate, RKRequestDelegate> {
  IBOutlet NSTextField *basecampDomain;
  IBOutlet NSTextField *basecampUsername;
  IBOutlet NSSecureTextField *basecampPassword;
  IBOutlet NSProgressIndicator *testConnectionProgress;
  IBOutlet NSImageView *testStatusImage;
  IBOutlet NSTextField *testStatusDescription;
  
  Settings *_settings;
}

- (IBAction)testConnection:(id)sender;

-(Settings*)settings;
@end
