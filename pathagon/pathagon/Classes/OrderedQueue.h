//
// Created by Johnny Sparks on 12/5/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//


#ifndef __OrderedQueue_H_
#define __OrderedQueue_H_

#import <Foundation/Foundation.h>

@interface OrderedQueue : NSObject {
    struct CBOQNode*	mObjs;
    unsigned			mCount;
    unsigned			mCapacity;
    BOOL				mHeapified;
}

- init;
- (unsigned)count;
- (void)addObject: (id)obj value: (unsigned)val;
- (id)pop;

@end


#endif //__OrderedQueue_H_
