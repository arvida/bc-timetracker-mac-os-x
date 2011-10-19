//
//  Company.m
//  bc-client
//
//  Created by arvid andersson on 2011/09/27.
//  Copyright 2011 winston design. All rights reserved.
//

#import "Company.h"

@implementation Company

@synthesize companyId;
@synthesize name;
@synthesize projects;

-(void)dealloc {
  [companyId release];
  [name release];
  [projects release];
  
  [super dealloc];
}

@end
