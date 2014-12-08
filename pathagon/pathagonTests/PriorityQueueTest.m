//
//  PriorityQueueTest.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "PriorityQueue.h"
#import "OrderedQueue.h"
#import <XCTest/XCTest.h>

@interface PriorityQueueTest : XCTestCase

@end

@implementation PriorityQueueTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmpty
{
    PriorityQueue *queue = [PriorityQueue new];
    XCTAssertEqual(queue.count, 0);
    XCTAssertNil(queue.pop);
}

- (void) testAddingObjects {
    PriorityQueue *queue = [PriorityQueue new];
    [queue add:@"a" priority:0];
    XCTAssertEqual(queue.count, 1);
    [queue add:@"a" priority:0];
    XCTAssertEqual(queue.count, 2);
    [queue add:@"a" priority:0];
    XCTAssertEqual(queue.count, 3);
    [queue add:@"a" priority:888];
    XCTAssertEqual(queue.count, 4);
    [queue add:@"a" priority:8138];
    XCTAssertEqual(queue.count, 5);
    [queue add:@"a" priority:8972879];
    XCTAssertEqual(queue.count, 6);
    [queue add:@"a" priority:0];
    XCTAssertEqual(queue.count, 7);
}

- (void) testPoppingObjectsInOrder {
    PriorityQueue *queue = [PriorityQueue new];
    [queue add:@"a" priority:12341234];
    [queue add:@"f" priority:1];
    [queue add:@"g" priority:0];
    [queue add:@"b" priority:9999];
    [queue add:@"c" priority:4];
    [queue add:@"a" priority:12341234];
    [queue add:@"b" priority:9999];
    [queue add:@"d" priority:3];
    [queue add:@"e" priority:2];
    
    NSLog(@"%@", queue);

    XCTAssert([queue.pop isEqualToString:@"g"]);
    XCTAssert([queue.pop isEqualToString:@"f"]);
    XCTAssert([queue.pop isEqualToString:@"e"]);
    XCTAssert([queue.pop isEqualToString:@"d"]);
    XCTAssert([queue.pop isEqualToString:@"c"]);
    XCTAssert([queue.pop isEqualToString:@"b"]);
    XCTAssert([queue.pop isEqualToString:@"b"]);
    XCTAssert([queue.pop isEqualToString:@"a"]);
    XCTAssert([queue.pop isEqualToString:@"a"]);
}

- (void) testPoppingOrderedQueueObjectsInOrder {
    OrderedQueue *queue = [OrderedQueue new];
    [queue addObject:@"a" value:12341];
    [queue addObject:@"f" value:1];
    [queue addObject:@"g" value:0];
    [queue addObject:@"b" value:9999];
    [queue addObject:@"c" value:4];
    [queue addObject:@"a" value:12341];
    [queue addObject:@"b" value:9999];
    [queue addObject:@"d" value:3];
    [queue addObject:@"e" value:2];
    
    NSLog(@"%@", queue);
    
    XCTAssert([queue.pop isEqualToString:@"g"]);
    XCTAssert([queue.pop isEqualToString:@"f"]);
    XCTAssert([queue.pop isEqualToString:@"e"]);
    XCTAssert([queue.pop isEqualToString:@"d"]);
    XCTAssert([queue.pop isEqualToString:@"c"]);
    XCTAssert([queue.pop isEqualToString:@"b"]);
    XCTAssert([queue.pop isEqualToString:@"b"]);
    XCTAssert([queue.pop isEqualToString:@"a"]);
    XCTAssert([queue.pop isEqualToString:@"a"]);
}

@end
