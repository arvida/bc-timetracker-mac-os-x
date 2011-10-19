//
//  DBManagedObjectCache.h
//  bc-timetracker-cd
//
//  Created by arvid andersson on 2011/10/02.
//  Copyright 2011 winston design. All rights reserved.
//

#import <RestKit/CoreData/RKManagedObjectCache.h>

/**
 * An implementation of the RestKit object cache. The object cache is
 * used to return locally cached objects that live in a known resource path.
 * This can be used to avoid trips to the network.
 */
@interface DBManagedObjectCache : NSObject <RKManagedObjectCache> {

}

@end
