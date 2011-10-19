//
//  Project.h
//  bc-client
//
//  Created by arvid andersson on 2011/09/19.
//  Copyright 2011 winston design. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "Company.h"

@interface Project : NSManagedObject

@property (nonatomic, retain) NSNumber* projectId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSNumber* assignedCompanyId;
@property (nonatomic, retain) Company* company;

@end
