//
//  BoardStructsTests.m
//  pathagon
//
//  Created by Johnny Sparks on 12/7/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "BoardStructs.h"

@interface BoardStructsTests : XCTestCase

@end

@implementation BoardStructsTests

- (void)testEmptyList {
    PieceList pieceList = PieceListMake();
    XCTAssert(pieceList.count == 0, @"list is empty");
}

- (void)testAddingPieces {
    PieceList list = PieceListMake();
    Player player = White;
    for(int x=0; x < boardSize - 1; x++){
        for(int y=0; y < boardSize - 1; y++) {
            Piece piece = MakePiece(OtherPlayer(player), PositionMake(x, y));
            PieceListAppend(&list, piece);
        }
    }
    XCTAssert(list.count = boardArea);
}

@end
