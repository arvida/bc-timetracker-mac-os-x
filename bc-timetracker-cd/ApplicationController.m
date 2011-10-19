//
//  ApplicationController.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/10.
//  Copyright 2011 winston design. All rights reserved.
//

#import "ApplicationController.h"

#import "Settings.h"
#import "Company.h"
#import "Project.h"
#import "Person.h"
#import "DBManagedObjectCache.h"

@implementation ApplicationController

@synthesize viewController;
@synthesize window;
@synthesize statusItem;
@synthesize statusItemView;
@synthesize view;
@synthesize preferencesController;

- (void)awakeFromNib
{
  [self setupStatusItem];
  if(![self checkIfSetupIsNeeded]){
    [self setupRestKit];
    [self refreshBasecampData];
  }
  [self setupTimeTrackerWindow];
  // [self toggleShowWindowFromPoint:[statusItemView getAnchorPoint]];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(refreshBasecampData)
   name:kNotificationProjectsNeedReload
   object:nil];}

- (void)toggleShowWindowFromPoint:(NSPoint)point
{
  [self.window setAttachPoint:point];
  [self.window toggleVisibility];
  
  [NSApp activateIgnoringOtherApps:YES];
}

-(IBAction)showPreferences:(id)sender
{
  if (!preferencesController) {
    self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesWindow"];
  }
  [self.window toggleVisibility]; 
  [preferencesController showWindow:self];
}

#pragma mark --
#pragma mark -- Setup

-(BOOL)checkIfSetupIsNeeded
{
  NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
  if([[defs stringForKey:kUserDefaultsDomain] length] == 0 ||
     [[defs stringForKey:kUserDefaultsUsername] length] == 0){
    NSAlert *alert = [NSAlert alertWithMessageText:@"Hi there," defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Looks like it's the first time you run %@. Nice to meet you!\n\nThe preference window will open so you can setup your Basecamp account details.\n\nHave a nice one!", kAppName];
    [alert runModal];
    [self showPreferences:self];
    return YES;
  }
  return NO;
}

-(void)setupStatusItem
{
  float width = 20; 
  float height = [[NSStatusBar systemStatusBar] thickness];
  NSRect statusItemFrame = NSMakeRect(0, 0, width, height);
  
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setHighlightMode:YES];
  
  self.statusItemView = [[CustomStatusItem alloc] initWithFrame:statusItemFrame];
  [statusItemView setDelegate:self];
  
  [statusItem setView:self.statusItemView];  
}

-(void)setupTimeTrackerWindow
{
  self.viewController = [[TimeTrackerController alloc] initWithNibName:@"TimeTrackerView" bundle:nil];
  viewController.appController = self;
  self.view = viewController.view;
  
  self.window = [[CustomWindow alloc] initWithView:self.view];
  [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
}

-(void)setupRestKit
{
  Settings* _settings = [[Settings alloc] init];  
  
  objectManager = [RKObjectManager objectManagerWithBaseURL:[_settings domainWithProtocol]];
  objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:kRestKitObjectCache];
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

-(void)reloadBasecampData
{
  [[RKClient sharedClient].requestCache invalidateAll];
  [self refreshBasecampData];
}

-(void)refreshBasecampData
{
  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProjectsUpdating object: nil];
  [objectManager loadObjectsAtResourcePath:@"/me.xml" delegate:self];
  [objectManager loadObjectsAtResourcePath:@"/projects.xml" delegate:self];
}
     
#pragma mark --
#pragma mark -- RestKit delegates

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProjectsUpdated object: nil];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {  
  NSLog(@"Hit error: %@", error);
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
  NSLog(@"Hit loadError: %@", error);
}

- (void)requestDidTimeout:(RKRequest *)request
{
  NSLog(@"Hit timeout");
}

     
@end
