//
//  AppController.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/01.
//  Copyright 2011 winston design. All rights reserved.
//

// ************************
//   NOT USED ANYMORE
// ************************

#import "AppController.h"

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "DBManagedObjectCache.h"

#import "Settings.h"
#import "Company.h"
#import "Project.h"
#import "Person.h"
#import "TimeEntry.h"

@implementation AppController

@synthesize preferencesController;
@synthesize statusItem;
@synthesize statusItemView;

-(void) awakeFromNib
{
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	int timesRun = (int)[defs integerForKey:kUserDefaultsTimesRun];
	if (!timesRun)
		timesRun = 1;
	else
		timesRun++;
	[defs setInteger:timesRun forKey:kUserDefaultsTimesRun]; 	
	[defs synchronize];
	NSLog(@"This app has been run %d times", timesRun);
  
  if([[defs stringForKey:kUserDefaultsDomain] length] == 0 ||
     [[defs stringForKey:kUserDefaultsUsername] length] == 0){
    NSAlert *alert = [NSAlert alertWithMessageText:@"Hi there," defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Looks like it's the first time you run %@. Nice to meet you!\n\nThe preference window will open so you can setup your Basecamp account details.", kAppName];
    [alert runModal];
    [self showPreferences:self];
  }
    
 // [self setUpRestKitObjectMappings];

  [dateField setDateValue:[NSDate date]];
 // [projectsPopUp setAutoenablesItems:NO];
 // [self reloadProjectsPopUp];
}

- (void)toggleShowWindowFromPoint:(NSPoint)point
{
  
}

-(IBAction)startTimer:(id)sender
{
  [timer dealloc];
  timer = [NSTimer scheduledTimerWithTimeInterval: 60
                                           target: self
                                         selector: @selector(handleTimer:)
                                         userInfo: nil
                                          repeats: YES];
  [startTimerButton setEnabled:NO];
  [stopTimerButton setEnabled:YES];
  [timeField setEnabled:NO];
}

-(IBAction)stopTimer:(id)sender
{
  [timer invalidate];
  [startTimerButton setEnabled:YES];
  [stopTimerButton setEnabled:YES];
  [timeField setEnabled:YES];
}

-(IBAction)handleTimer:(id)timer 
{
  float inc = 0.01;
  NSNumber *currentHours = [[NSNumber alloc] initWithFloat:([timeField floatValue]+inc)];
  [timeField setFloatValue:[currentHours floatValue]];
}

-(IBAction)submitTime:(id)sender 
{
  [progressIndicator setHidden:NO];
  [progressIndicator startAnimation:self];
  [submitButton setEnabled:NO];
  TimeEntry *timeEntry  = [[TimeEntry alloc] initWithPerson:[[[Settings alloc] init] person]
                                                       date:[dateField dateValue]
                                                      hours:[timeField stringValue]
                                                description:[descriptionField stringValue]];
  
  NSString *_url = [NSString stringWithFormat:@"/projects/%@/time_entries.xml", [[[projectsPopUp selectedItem] representedObject] projectId]];
  [[RKClient sharedClient] post:_url params:timeEntry delegate:self]; 
  Settings *settings = [[Settings alloc] init];
  [settings setLastSelectedProjectValue:[[projectsPopUp selectedItem] title]];
  [settings save];
}

- (IBAction)showPreferences:(id)sender
{
  if (!preferencesController) {
    self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
  }
  
  [preferencesController showWindow:self];
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
  
  [projectsPopUp selectItemAtIndex:1];
  Settings *settings = [Settings current];
  if([[settings lastSelectedProject] isNotEqualTo:@""]){
    [projectsPopUp selectItemWithTitle:[settings lastSelectedProject]];
  }
}

-(void)setUpRestKitObjectMappings {
  Settings* _settings = [[Settings alloc] init];  
  NSLog(@" Domain: %@", [_settings domain]);
  NSLog(@" Username: %@", [_settings username]);
  NSLog(@" Password: %@", [_settings password]);
  
  
  objectManager = [RKObjectManager objectManagerWithBaseURL:[_settings domainWithProtocol]];
  objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"bc-time-tracker-cd.sqlite"];
  objectManager.objectStore.managedObjectCache = [[DBManagedObjectCache new] autorelease];

  
  objectManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
  objectManager.client.username = [_settings username]; 
  objectManager.client.password = [_settings password];
  
  RKManagedObjectMapping* projectMapping = [RKManagedObjectMapping mappingForClass:[Project class]];
  RKManagedObjectMapping* companyMapping = [RKManagedObjectMapping mappingForClass:[Company class]];
  
  [projectMapping mapKeyPath:@"id" toAttribute:@"projectId"];
  [projectMapping mapKeyPath:@"name" toAttribute:@"name"];
  [projectMapping mapKeyPath:@"company.id" toAttribute:@"assignedCompanyId"];
  [projectMapping mapKeyPath:@"company" toRelationship:@"company" withMapping:companyMapping];
  [projectMapping setPrimaryKeyAttribute:@"projectId"];
  [objectManager.mappingProvider setMapping:projectMapping forKeyPath:@"projects.project"];
  
  [companyMapping mapKeyPath:@"name" toAttribute:@"name"];
  [companyMapping mapKeyPath:@"id" toAttribute:@"companyId"];
  [companyMapping mapRelationship:@"projects" withMapping:projectMapping];
  [companyMapping setPrimaryKeyAttribute:@"companyId"];
  [objectManager.mappingProvider setMapping:companyMapping forKeyPath:@"projects.project.company"];
  
  [objectManager.mappingProvider setMapping:projectMapping forKeyPath:@"projects"];
  [objectManager.mappingProvider setMapping:companyMapping forKeyPath:@"projects"];
  [objectManager loadObjectsAtResourcePath:@"/projects.xml" delegate:self];
  
  RKManagedObjectMapping* personMapping = [RKManagedObjectMapping mappingForClass:[Person class]];
  [personMapping mapKeyPath:@"id" toAttribute:@"personId"];
  [personMapping mapKeyPath:@"first-name" toAttribute:@"firstName"];
  [personMapping mapKeyPath:@"last-name" toAttribute:@"lastName"];
  [personMapping setPrimaryKeyAttribute:@"personId"];
  [objectManager.mappingProvider setMapping:personMapping forKeyPath:@"person"];
  [objectManager loadObjectsAtResourcePath:@"/me.xml" delegate:self];
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

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
  //NSLog(@"Load collection of Projects: %@", objects);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
  //NSLog(@"Loaded payload: %@\n\n", [response bodyAsString]);
  if ([response isCreated]) { 
    [timeField setStringValue:@"00.00"];
    [descriptionField setStringValue:@""];
  }
  [progressIndicator setHidden:YES];
  [submitButton setEnabled:YES];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {  
  NSLog(@"Hit error: %@", error);
}


@end
