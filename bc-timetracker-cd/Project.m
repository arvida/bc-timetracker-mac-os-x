//
//  Project.m
//  bc-client
//
//  Created by arvid andersson on 2011/09/19.
//  Copyright 2011 winston design. All rights reserved.
//

#import "Project.h"
#import <objc/runtime.h>

@implementation Project

@synthesize projectId;
@synthesize name;
@synthesize assignedCompanyId;
@synthesize company;

-(void)dealloc {
  [projectId release];
  [name release];
  [assignedCompanyId release];
  [company release];
  
  [super dealloc];
}
@end
