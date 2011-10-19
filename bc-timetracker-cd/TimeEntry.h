//
//  TimeEntry.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/02.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h> 

#import "Person.h"

@interface TimeEntry : NSObject<RKRequestSerializable> { 
  Person *person; 
  NSDate *date;
  NSString *hours;
  NSString *description;
  NSData *body; 
  NSUInteger length; 
  NSString *contentType; 
} 

@property(nonatomic, retain) Person *person; 
@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) NSString *hours;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSData *body; 
@property(nonatomic, assign) NSUInteger length; 
@property(nonatomic, retain) NSString *contentType; 

- (id) initWithPerson:(Person*) _person 
         date:(NSDate*)_date
         hours:(NSString*)_hours
         description:(NSString*)_description; 

@end
