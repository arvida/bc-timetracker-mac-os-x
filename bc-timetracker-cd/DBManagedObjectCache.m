//
//  DBManagedObjectCache.m
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/02.
//  Copyright 2011 winston design. All rights reserved.
//

#import "DBManagedObjectCache.h"
#import "Project.h"

@implementation DBManagedObjectCache

- (NSArray*)fetchRequestsForResourcePath:(NSString*)resourcePath {
	if ([resourcePath isEqualToString:@"/projects.xml"]) {
		NSFetchRequest* request = [Project fetchRequest];
		NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		return [NSArray arrayWithObject:request];
	}
	
	return nil;
}

@end
