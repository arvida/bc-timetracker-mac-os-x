//
//  ApplicationController.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/10.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#import "CustomWindow.h"
#import "CustomStatusItem.h"

#import "TimeTrackerController.h"
#import "PreferencesController.h"

@interface ApplicationController : NSObject <CustomStatusItemDelegate, RKRequestDelegate, RKObjectLoaderDelegate> {
  NSTimer *timer;
  
  RKClient* client;
  RKObjectManager* objectManager;
  
  CustomWindow *window;
  NSStatusItem *statusItem;
  CustomStatusItem *statusItemView;
  NSView *view;
}

@property (retain) TimeTrackerController *viewController;
@property (retain) CustomWindow *window;
@property (retain) NSStatusItem *statusItem;
@property (retain) CustomStatusItem *statusItemView;
@property (retain) IBOutlet NSView *view;

@property (retain) PreferencesController *preferencesController;

-(void)toggleShowWindowFromPoint:(NSPoint)point;

-(BOOL)checkIfSetupIsNeeded;
-(void)setupStatusItem;
-(void)setupTimeTrackerWindow;
-(void)setupRestKit;
-(void)reloadBasecampData;
-(void)refreshBasecampData;

@end