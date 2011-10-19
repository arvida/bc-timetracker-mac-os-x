//
//  bc_timetracker_cdAppDelegate.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/01.
//  Copyright 2011 winston design. All rights reserved.
//

#import "bc_timetracker_cdAppDelegate.h"

@implementation bc_timetracker_cdAppDelegate

@synthesize window;

+ (void)initialize
{
  NSLog(@" ** initialize");
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:0], kUserDefaultsTimesRun,
                            @"", kUserDefaultsDomain, 
                            @"", kUserDefaultsUsername,nil];
  [defs registerDefaults:defaults];
	[defs synchronize];
  NSLog(@" ** initialize done");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@" ** applicationDidFinishLaunching");
}

@end
