//
//  PriorityQueue.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "PriorityQueue.h"

@interface PriorityQueue ()
@property (nonatomic, strong) NSMutableDictionary *buckets;
@property (nonatomic) NSUInteger lastPriority;
@end

@implementation PriorityQueue {
    NSUInteger _count;
}

-(id) init {
    if(self = [super init]){
        _buckets = [NSMutableDictionary new];
        _count = 0;
        _lastPriority = NSUIntegerMax;
    }
    return self;
}

- (id) pop {
    id item;
    NSUInteger minPriority = NSUIntegerMax;
    NSArray *priorities = self.buckets.allKeys;
    for(NSNumber *priorityNumber in priorities){
        NSMutableDictionary *bucket = self.buckets[priorityNumber];
        if(!bucket.count){
            [self.buckets removeObjectForKey:priorityNumber];
        } else {
            NSUInteger priority = priorityNumber.unsignedIntegerValue;
            minPriority = MIN(priority, minPriority);
        }
    }
    if(minPriority != NSUIntegerMax){
        NSMutableArray *items = self.buckets[@(minPriority)];
        item = items.lastObject;
        [items removeLastObject];
        _count -= 1;
        _lastPriority = minPriority;
    }
    return item;
}

- (void) add:(id) obj priority:(NSUInteger)priority {
    NSNumber *priorityNumber = @(priority);
    if(!self.buckets[priorityNumber]){
        self.buckets[priorityNumber] = [NSMutableArray new];
    }
    [self.buckets[priorityNumber] addObject:obj];
    _count += 1;
}

-(NSUInteger)count {
    return _count;
}

-(void) setCount:(NSUInteger)count {
    _count = count;
}

- (id) copyWithZone:(NSZone *)zone {
    PriorityQueue *q = [PriorityQueue new];
    PriorityQueue *q2 = [PriorityQueue new];
    while (self.count) {
        id item = self.pop;
        [q add:item priority:self.lastPriority];
        [q2 add:item priority:self.lastPriority];
    }
    while (q2.count) {
        [self add:q2.pop priority:q2.lastPriority];
    }
    return q;
}

- (NSString *) description {
    PriorityQueue *q = [self copy];
    NSMutableString *s = [@"\nPriorityQueue: {" mutableCopy];
    while (q.count) {
        id item = q.pop;
        [s appendFormat:@"\n(%lu %@)", (unsigned long)q.lastPriority, item];
    }
    [s appendString:@"\n}"];
    return s;
}


@end
