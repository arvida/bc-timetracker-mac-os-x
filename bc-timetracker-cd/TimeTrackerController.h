//
//  TimeTrackerController.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/11.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <RestKit/RestKit.h>

@class ApplicationController;

@interface TimeTrackerController : NSViewController <RKRequestDelegate> {
  NSTimer *timer;
  
  IBOutlet NSTextField *hoursField;
  IBOutlet NSDatePicker *dateField;
  IBOutlet NSPopUpButton *projectsPopUp;
  IBOutlet NSTextField *descriptionField;
  IBOutlet NSProgressIndicator *progressIndicator;
  IBOutlet NSButton *submitButton;
  IBOutlet NSButton *startTimerButton;
  IBOutlet NSButton *stopTimerButton;
}

@property (retain) ApplicationController *appController;

-(IBAction)handleTimer:(id)timer;
-(IBAction)startTimer:(id)sender;
-(IBAction)stopTimer:(id)sender;
-(IBAction)showPreferences:(id)sender;
-(IBAction)submitTime:(id)sender;

-(void)reloadProjectsPopUp;
-(NSArray*)getCompanies;

@end
