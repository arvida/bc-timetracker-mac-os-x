//
//  Person.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/02.
//  Copyright 2011 winston design. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber* personId;
@property (nonatomic, retain) NSString* firstName;
@property (nonatomic, retain) NSString* lastName;

@end
