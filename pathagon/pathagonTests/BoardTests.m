//
//  BoardTests.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Board.h"

@interface BoardTests : XCTestCase

@end

@implementation BoardTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
    
    PieceList pieceList = [board piecesTrappedBy:MakePiece(White, PositionMake(2, 2))];
    
    XCTAssertEqual(pieceList.count, 4);
    int loops = 0;
    while (!PieceListIsEmpty(&pieceList)) {
        Piece piece = PieceListNextPiece(&pieceList);
        XCTAssert(piece.player == Black);
        loops ++;
    }
    XCTAssertEqual(loops, 4);
}


@end
