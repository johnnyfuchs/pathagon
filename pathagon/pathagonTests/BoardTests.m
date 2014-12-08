//
//  BoardTests.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Board.h"

@interface Board (Tests)
- (BOOL) pathExistsFrom:(Piece) start to:(Piece) finish;
- (PieceList)connectedPieces:(Piece)piece;
- (PieceList) allPieces;
- (void) remove:(Piece)piece;
@end

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

- (void) testRemovesPieces {
    Board * board = [Board new];
    [board add:MakePiece(White, PositionMake(1, 2))];
    NSLog(@"%@", board);
    [board add:MakePiece(White, PositionMake(0, 1))];
        NSLog(@"%@", board);
    [board add:MakePiece(White, PositionMake(2, 3))];
        NSLog(@"%@", board);
    [board add:MakePiece(White, PositionMake(1, 3))];
        NSLog(@"%@", board);
    
    [board add:MakePiece(Black, PositionMake(3, 4))];
        NSLog(@"%@", board);
    [board add:MakePiece(Black, PositionMake(2, 5))];
        NSLog(@"%@", board);
    [board add:MakePiece(Black, PositionMake(4, 5))];
        NSLog(@"%@", board);
    [board add:MakePiece(Black, PositionMake(2, 6))];
        NSLog(@"%@", board);
    
    XCTAssertEqual([board allPieces].count, 8);
    
    [board remove:MakePiece(White, PositionMake(1, 2))];
            NSLog(@"%@", board);
    [board remove:MakePiece(White, PositionMake(0, 1))];
            NSLog(@"%@", board);
    [board remove:MakePiece(White, PositionMake(2, 3))];
            NSLog(@"%@", board);
    [board remove:MakePiece(White, PositionMake(1, 3))];
            NSLog(@"%@", board);
    
    XCTAssertEqual([board allPieces].count, 4);
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


- (void) testPlayablePieces {
    Board *board = [Board new];
    PieceList list = [board playablePieces];
    XCTAssertEqual(list.count, boardArea);
}

- (void) testPlayablePiecesAlmostFull {
    Board *board = [Board new];
    
    for(int x = 0; x < boardSize; x++){
        for (int y=1; y < boardSize; y++) {
            [board add:MakePiece(White, PositionMake(x, y))];
        }
    }
    PieceList list = [board playablePieces];
    XCTAssertEqual(list.count, 7);
}


- (void) testConnectedPieces {
    Board * board = [Board new];
    [board add:MakePiece(Black, PositionMake(1, 2))];
    [board add:MakePiece(Black, PositionMake(2, 1))];
    [board add:MakePiece(Black, PositionMake(2, 3))];
    [board add:MakePiece(Black, PositionMake(3, 2))];
    
    PieceList list = [board connectedPieces:MakePiece(Black, PositionMake(2, 2))];
    
    XCTAssertEqual(list.count, 4);
}

- (void) testConnectedPiecesPartial {
    Board * board = [Board new];
    [board add:MakePiece(Black, PositionMake(2, 2))];
    [board add:MakePiece(Black, PositionMake(3, 1))];
    [board add:MakePiece(Black, PositionMake(4, 2))];
    
    PieceList list = [board connectedPieces:MakePiece(Black, PositionMake(3, 2))];
    
    XCTAssertEqual(list.count, 3);
}

- (void) testConnectedPiecesExtraPiece {
    Board * board = [Board new];
    [board add:MakePiece(Black, PositionMake(2, 2))];
    [board add:MakePiece(Black, PositionMake(3, 6))];
    [board add:MakePiece(Black, PositionMake(4, 2))];
    
    PieceList list = [board connectedPieces:MakePiece(Black, PositionMake(3, 2))];
    
    XCTAssertEqual(list.count, 2);
}

-(void) testAdjacentPath {
    Board *board = [Board new];
    Piece start = MakePiece(White, PositionMake(3, 0));
    Piece to = MakePiece(White, PositionMake(3, 1));
    [board add:start];
    [board add:to];
    XCTAssert([board pathExistsFrom:start to:to]);
}

-(void) testPathExists {
    Board *board = [Board new];
    Piece start = MakePiece(White, PositionMake(3, 0));
    Piece to = MakePiece(White, PositionMake(3, boardSize - 1));
    
    for(int row=0;row<boardSize; row++){
        [board add:MakePiece(White, PositionMake(3, row))];
    }
    
    XCTAssert([board pathExistsFrom:start to:to]);

}

@end
