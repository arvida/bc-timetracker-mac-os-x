//
//  TimeTrackerController.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/11.
//  Copyright 2011 winston design. All rights reserved.
//

#import "TimeTrackerController.h"
#import "Company.h"
#import "Project.h"
#import "Settings.h"
#import "TimeEntry.h"

@implementation TimeTrackerController

@synthesize appController;

- (void)awakeFromNib
{
  [dateField setDateValue:[NSDate date]];
  [projectsPopUp setAutoenablesItems:NO];
  [self reloadProjectsPopUp];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(reloadProjectsPopUp)
   name:kNotificationProjectsUpdated
   object:nil];
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(disableProjectsPopUp:)
   name:kNotificationProjectsUpdating
   object:nil];
}

-(IBAction)showPreferences:(id)sender
{
  [appController showPreferences:self];
}

-(IBAction)startTimer:(id)sender
{
  [timer dealloc];
  timer = [NSTimer scheduledTimerWithTimeInterval: 60*5 // update time every 5 minutes
                                           target: self
                                         selector: @selector(handleTimer:)
                                         userInfo: nil
                                          repeats: YES];
  [startTimerButton setEnabled:NO];
  [stopTimerButton setEnabled:YES];
  [hoursField setEnabled:NO];
}

-(IBAction)stopTimer:(id)sender
{
  [timer invalidate];
  [startTimerButton setEnabled:YES];
  [stopTimerButton setEnabled:YES];
  [hoursField setEnabled:YES];
}

-(IBAction)handleTimer:(id)timer 
{
  float inc = 0.0166666667; // 0.0166666667*60 ≈ 1
  NSNumber *currentHours = [[NSNumber alloc] initWithFloat:([hoursField floatValue]+inc)];
  [hoursField setFloatValue:[currentHours floatValue]];
}

-(IBAction)submitTime:(id)sender 
{
  [progressIndicator setHidden:NO];
  [progressIndicator startAnimation:self];
  [submitButton setEnabled:NO];
  TimeEntry *timeEntry  = [[TimeEntry alloc] initWithPerson:[[[Settings alloc] init] person]
                                                       date:[dateField dateValue]
                                                      hours:[hoursField stringValue]
                                                description:[descriptionField stringValue]];
  
  NSString *_url = [NSString stringWithFormat:@"/projects/%@/time_entries.xml", [[[projectsPopUp selectedItem] representedObject] projectId]];
  [[RKClient sharedClient] post:_url params:timeEntry delegate:self]; 
  Settings *settings = [[Settings alloc] init];
  [settings setLastSelectedProjectValue:[[projectsPopUp selectedItem] title]];
  [settings save];
}

-(IBAction)disableProjectsPopUp:(id)sender
{
  [projectsPopUp setEnabled:NO];
}

#pragma mark --
#pragma mark Interface setup

-(void) reloadProjectsPopUp 
{
  [projectsPopUp removeAllItems];
  NSArray *companies = [self getCompanies];
  [companies enumerateObjectsUsingBlock:^(Company* company, NSUInteger idx, BOOL *stop) {
    NSMenu* projectMenu = [projectsPopUp menu];
    if([company.projects count] > 0){
      NSMenuItem *theCompanyMenuItem = [[[NSMenuItem alloc] 
                                         initWithTitle:company.name 
                                         action:nil keyEquivalent:@""] autorelease]; 
      [theCompanyMenuItem setRepresentedObject:company];
      [theCompanyMenuItem setEnabled:NO];
      [projectMenu addItem:theCompanyMenuItem];
      
      [company.projects enumerateObjectsUsingBlock:^(Project* project, BOOL *stop){
        NSMenuItem *theProjectMenuItem = [[[NSMenuItem alloc] 
                                           initWithTitle:[NSString stringWithFormat:@"  %@", project.name]
                                           action:nil keyEquivalent:@""] autorelease]; 
        [theProjectMenuItem setRepresentedObject:project];
        [theProjectMenuItem setEnabled:YES];
        [projectMenu addItem:theProjectMenuItem];
      }];
    }
  }];
  
  [projectsPopUp setEnabled:YES];
  [projectsPopUp selectItemAtIndex:1];
  Settings *settings = [Settings current];
  if([[settings lastSelectedProject] isNotEqualTo:@""]){
    [projectsPopUp selectItemWithTitle:[settings lastSelectedProject]];
  }
}

#pragma mark --
#pragma mark -- Data

-(NSArray*) getCompanies {
  NSFetchRequest* request = [Company fetchRequest];
  [request setReturnsObjectsAsFaults:NO];
  [request setRelationshipKeyPathsForPrefetching: [NSArray arrayWithObject:@"projects"]];
  NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
  [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != ''"];
  [request setPredicate:predicate];
  
  return [[Company objectsWithFetchRequest:request] retain];
}

#pragma mark --
#pragma mark -- RestKit delegates

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response 
{
  //NSLog(@"Loaded payload: %@\n\n", [response bodyAsString]);
  if ([response isCreated]) { 
    [hoursField setStringValue:@"00.00"];
    [descriptionField setStringValue:@""];
    [dateField setDateValue:[NSDate date]];
  }
  [progressIndicator setHidden:YES];
  [submitButton setEnabled:YES];
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
  [appController request:request didFailLoadWithError:error];
}

- (void)requestDidTimeout:(RKRequest *)request
{
  [appController requestDidTimeout:request];
}

@end
