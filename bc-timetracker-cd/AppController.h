//
//  AppController.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/01.
//  Copyright 2011 winston design. All rights reserved.
//

// ************************
//   NOT USED ANYMORE
// ************************


#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#import "CustomWindow.h"
#import "CustomStatusItem.h"

#import "Settings.h"
#import "PreferencesController.h"

@interface AppController : NSWindowController <CustomStatusItemDelegate, RKRequestDelegate, RKObjectLoaderDelegate> {  
  NSTimer *timer;

  IBOutlet NSTextField *timeField;
  IBOutlet NSDatePicker *dateField;
  IBOutlet NSPopUpButton *projectsPopUp;
  IBOutlet NSTextField *descriptionField;
  IBOutlet NSProgressIndicator *progressIndicator;
  IBOutlet NSButton *submitButton;
  IBOutlet NSButton *startTimerButton;
  IBOutlet NSButton *stopTimerButton;
    
  RKClient* client;
  RKObjectManager* objectManager;
  
  NSStatusItem *statusItem;
  CustomStatusItem *statusItemView;
}
@property (retain) NSStatusItem *statusItem;
@property (retain) CustomStatusItem *statusItemView;

@property (retain) PreferencesController *preferencesController;

- (void)toggleShowWindowFromPoint:(NSPoint)point;

-(IBAction)submitTime:(id)sender;
-(IBAction)startTimer:(id)sender;
-(IBAction)stopTimer:(id)sender;
- (IBAction)showPreferences:(id)sender;

-(void)setUpRestKitObjectMappings;
-(NSArray*)getCompanies;

-(void)reloadProjectsPopUp;


@end
