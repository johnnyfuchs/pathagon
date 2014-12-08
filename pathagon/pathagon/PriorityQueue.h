//
//  PriorityQueue.h
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriorityQueue : NSObject <NSCopying>

- (NSUInteger)count;
- (id) pop;
- (void) add:(id) obj priority:(NSUInteger)priority;

@end
