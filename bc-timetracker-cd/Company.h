//
//  Company.h
//  bc-client
//
//  Created by arvid andersson on 2011/09/27.
//  Copyright 2011 winston design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSManagedObject

@property (nonatomic, retain) NSNumber* companyId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSSet* projects;

@end
