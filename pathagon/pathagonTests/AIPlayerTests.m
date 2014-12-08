//
//  AIPlayer.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Board.h"
#import "AIPlayer.h"

@interface AIPlayerTests : XCTestCase

@end

@implementation AIPlayerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHueristicNoLastPiece {
    Board *b = [Board new];
    
    XCTAssertGreaterThanOrEqual(heuristic(b), 0);
    XCTAssertLessThan(heuristic(b), 10);
    XCTAssertGreaterThanOrEqual(heuristic(b), 0);
    XCTAssertLessThan(heuristic(b), 10);
}

- (void)testHueristicWin {
    Board *b = [Board new];
    
    for (int row = 0; row < boardSize; row ++) {
        [b add:MakePiece(White, PositionMake(4, row))];
    }
    
    XCTAssertEqual(heuristic(b), 99999);
}


- (void)testPiecesTrappedBy {

    Board * board = [Board new];
    [board add:MakePiece(White, PositionMake(0, 2))];
    [board add:MakePiece(White, PositionMake(2, 4))];
    [board add:MakePiece(White, PositionMake(2, 0))];
    [board add:MakePiece(White, PositionMake(4, 2))];
    
    [board add:MakePiece(Black, PositionMake(1, 2))];
    [board add:MakePiece(Black, PositionMake(2, 1))];
    [board add:MakePiece(Black, PositionMake(2, 3))];
    [board add:MakePiece(Black, PositionMake(3, 2))];
    
    [board add:MakePiece(Black, PositionMake(2, 2))];
    
    XCTAssertEqual(heuristic(board), 40);
}
@end
