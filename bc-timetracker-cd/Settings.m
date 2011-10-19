//
//  Settings.m
//  bc-client
//
//  Created by arvid andersson on 2011/09/19.
//  Copyright 2011 winston design. All rights reserved.
//


#define kKeychainAccountName @"Default"

#import "Settings.h"

#import "HAKeychain.h"

@implementation Settings

@synthesize domain;
@synthesize username;
@synthesize password;
@synthesize lastSelectedProject;

+(Settings*) current 
{
  return [[Settings alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
      preferences = [NSUserDefaults standardUserDefaults];

      domain = [preferences stringForKey:kUserDefaultsDomain];
      username = [preferences stringForKey:kUserDefaultsUsername];
      password = [self findOrCreatePassword];
      lastSelectedProject = [preferences stringForKey:kUserDefaultsLastSelectedProject];
    }
    
    return self;
}

-(void)setDomainValue:(NSString*)value 
{
  if([domain isNotEqualTo:value]){
    domain = value;
    domainTouched = YES;
  }
}

-(void)setUsernameValue:(NSString*)value
{
  if([username isNotEqualTo:value]){
    username = value;
    usernameTouched = YES;
  }
}

-(void)setPasswordValue:(NSString*)value
{
  if([password isNotEqualTo:value]){
    password = value;
    passwordTouched = YES;
  }
}

-(void)setLastSelectedProjectValue:(NSString*)value
{
  if([lastSelectedProject isNotEqualTo:value]){
    lastSelectedProject = value;
    lastSelectedProjectTouched = YES;
  }
}

-(NSString*)domainWithProtocol
{
  return [NSString stringWithFormat:@"https://%@", domain];
}

-(Person*)person
{
  NSFetchRequest* request = [Person fetchRequest];
  [request setReturnsObjectsAsFaults:NO];
  
  return [[Person objectWithFetchRequest:request] retain];
}

-(BOOL)touched
{
  if(domainTouched || usernameTouched || passwordTouched || lastSelectedProjectTouched){
    return true;
  }else{
    return false;
  }
}

-(void)untouch 
{
  domainTouched = NO;
  usernameTouched = NO;
  passwordTouched = NO;
  lastSelectedProjectTouched = NO;
}

-(void)save 
{
  if(domainTouched){
    [preferences setValue:domain forKey:kUserDefaultsDomain];
  }
  if(usernameTouched){
    [preferences setValue:username forKey:kUserDefaultsUsername];
  }
  if(lastSelectedProjectTouched){
    [preferences setValue:lastSelectedProject forKey:kUserDefaultsLastSelectedProject];
  }
  
  if(passwordTouched){
    NSError *error = nil;
    BOOL updated = [HAKeychain updatePassword:password
                                   forService:kAppName
                                      account:kKeychainAccountName
                                     keychain:NULL
                                        error:&error];
    if (!updated && error) {
      NSLog(@"Keychain error - %@", error);
    }
  }
  
  if([self touched]){
    [preferences synchronize];
    [self untouch];
  }
}

-(void) dealloc
{
  [lastSelectedProject release];
  [domain release];
  [username release];
  [password release];
  [preferences release];
  
  [super dealloc];
}

-(NSString*)findOrCreatePassword 
{
  NSError *error = nil;
  NSString *foundPassword = [HAKeychain findPasswordForService:kAppName
                                                       account:kKeychainAccountName
                                                      keychain:NULL
                                                         error:&error];
  if (!error) {
    return foundPassword;
  }else{
    NSLog(@"Keychain find password error - %@", error);
    if(error.code == errSecItemNotFound){
      NSError *createError = nil;
      [HAKeychain createPassword:@""
                      forService:kAppName
                         account:kKeychainAccountName
                        keychain:NULL
                           error:&createError];
      if(createError){
        NSLog(@"  Keychain create password error - %@", createError);
      }
    }
  }
  return @"";
}

@end
