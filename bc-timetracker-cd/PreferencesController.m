//
//  PreferencesController.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/06.
//  Copyright 2011 winston design. All rights reserved.
//


#import "PreferencesController.h"

#import "XML/RKXMLParserLibXML.h"

@implementation PreferencesController

- (void)awakeFromNib
{
  NSLog(@" ** PreferencesController awakeFromNib");
  [basecampDomain setStringValue:[self settings].domain];
  [basecampUsername setStringValue:[self settings].username];
  [basecampPassword setStringValue:[self settings].password];
}

- (void)windowWillClose:(NSNotification *)notification {
  NSLog(@" ** PreferencesController windowWillClose");
  [[self settings] setDomainValue:[basecampDomain stringValue]];
  [[self settings] setUsernameValue:[basecampUsername stringValue]];
  [[self settings] setPasswordValue:[basecampPassword stringValue]];
  [[self settings] save];
  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationProjectsNeedReload object: nil];
  [testStatusImage setHidden:YES];
  [testStatusDescription setHidden:YES];
  [self autorelease];
}

- (IBAction)testConnection:(id)sender 
{
  [testStatusImage setHidden:YES];
  [testStatusDescription setHidden:YES];
  [testConnectionProgress setHidden:NO];
  [testConnectionProgress startAnimation:self];
  
  RKClient* client = [RKClient clientWithBaseURL:[NSString stringWithFormat:@"https://%@", [basecampDomain stringValue]]];
  client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
  client.username = [basecampUsername stringValue]; 
  client.password = [basecampPassword stringValue]; 
  
  [client get:@"/me.xml" delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
  NSString *statusDescription;
  NSImage *statusImage;
  
  [testConnectionProgress setHidden:YES];
  [testConnectionProgress stopAnimation:self];
  
  if([response isOK]){
    NSError *error = nil; 
    id parsedResponse = [response parsedBody:&error];

    if(error){
      statusImage = [NSImage imageNamed:@"Status_Declined.png"];
      statusDescription = [NSString stringWithFormat:@"Unknown error: %@", error.description];
    }else{
      statusImage = [NSImage imageNamed:@"Status_Accepted.png"];
      statusDescription = [NSString stringWithFormat:@"Logged in successfully as %@ %@", [[parsedResponse valueForKey:@"person"] valueForKey:@"first-name"], [[parsedResponse valueForKey:@"person"] valueForKey:@"last-name"] ];
    }
  }else{
    statusImage = [NSImage imageNamed:@"Status_Declined.png"];
    statusDescription = [NSString stringWithFormat:@"Login failed", response.statusCode];
  }
  
  [testStatusImage setImage:statusImage];
  [testStatusDescription setStringValue:statusDescription];
  
  [testStatusImage setHidden:NO];
  [testStatusDescription setHidden:NO];
}

-(void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
  [testConnectionProgress setHidden:YES];
  [testConnectionProgress stopAnimation:self];
  
  [testStatusImage setImage:[NSImage imageNamed:@"Status_Declined.png"]];
  [testStatusDescription setStringValue:@"Login failed"];
  
  [testStatusImage setHidden:NO];
  [testStatusDescription setHidden:NO];
}

-(Settings*)settings 
{
  if(!_settings){
    _settings = [Settings current];
  }
  
  return _settings;  
}

@end
