//
//  TimeEntry.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/02.
//  Copyright 2011 winston design. All rights reserved.
//

#import "TimeEntry.h"


@implementation TimeEntry

@synthesize person; 
@synthesize date;
@synthesize hours;
@synthesize description;
@synthesize body; 
@synthesize length; 
@synthesize contentType; 

- (id) initWithPerson:(Person*) _person 
                 date:(NSDate*) _date
                hours:(NSString*) _hours
          description:(NSString*) _description 
{
  self = [super init]; 
  if (self) { 
    [self setPerson:_person]; 
    [self setDate:_date]; 
    [self setHours:_hours]; 
    [self setDescription:_description]; 
    [self setContentType:@"application/xml"];
    
    NSString *xmlBody;
    xmlBody = [NSString stringWithFormat:@"<time-entry><date>%@</date><description>%@</description><hours>%@</hours><person-id>%@</person-id></time-entry>", [date description], description, hours, person.personId];
    [self setBody:[xmlBody dataUsingEncoding:NSUTF8StringEncoding]];
  } 
  return self; 
}

- (NSData *) HTTPBody { 
  return self.body; 
} 

- (NSUInteger)HTTPHeaderValueForContentLength { 
  return [self.body length]; 
} 

- (NSString *)HTTPHeaderValueForContentType { 
  return self.contentType; 
} 

@end
