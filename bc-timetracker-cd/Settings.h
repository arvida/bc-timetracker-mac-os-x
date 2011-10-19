//
//  Settings.h
//  bc-client
//
//  Created by arvid andersson on 2011/09/19.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Settings : NSObject {
  NSUserDefaults* preferences;
  NSString* domain;
  NSString* username;
  NSString* password;
  NSString* lastSelectedProject;
  BOOL domainTouched;
  BOOL usernameTouched;
  BOOL passwordTouched;
  BOOL lastSelectedProjectTouched;
}
@property(readonly, retain) NSString* domain;
@property(readonly, retain) NSString* username;
@property(readonly, retain) NSString* password;
@property(readonly, retain) NSString* lastSelectedProject;

-(void)setDomainValue:(NSString*)value;
-(void)setUsernameValue:(NSString*)value;
-(void)setPasswordValue:(NSString*)value;
-(void)setLastSelectedProjectValue:(NSString*)value;

-(NSString*)domainWithProtocol;

+(Settings*) current;

-(NSString*)findOrCreatePassword;
-(Person*)person;
-(BOOL)touched;
-(void)untouch;
-(void)save;

@end
