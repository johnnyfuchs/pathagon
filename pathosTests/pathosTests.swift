//
//  pathosTests.swift
//  pathosTests
//
//  Created by Johnny Sparks on 7/18/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import XCTest
import pathos

class pathosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDirectionAddition() {
        let oneone = Position(2,2)
        
        let north = oneone + Direction.N.toCoord()
        XCTAssertEqual(north.y, 1 , "North is up one")
    
        let south = oneone + Direction.S.toCoord()
        XCTAssertEqual(south.y, 3 , "south is down")
        
        let east = oneone + Direction.E.toCoord()
        XCTAssertEqual(east.x, 3 , "east is right")
        
        let west = oneone + Direction.W.toCoord()
        XCTAssertEqual(west.x, 1 , "west is left")
    }
    
    func testPositionsEqual() {
        let a = Position(123, 321)
        let b = Position(123, 321)
        let c = Position(7, 321)
        
        XCTAssert(a == b, "positions are equal")
        XCTAssertFalse(a == c, "positions are not equal")
        XCTAssert(a !== c, "positions are not equal")
    }
    
    func testSurroundingPieces() {
        let playerOne = Player(name:"one")
        let playerTwo = Player(name:"two")
        let board = Board(size: 8)
        let a = Piece(playerOne, Position(1,2))
        let b = Piece(playerOne, Position(2,1))
        let c = Piece(playerOne, Position(2,3))
        let d = Piece(playerOne, Position(3,2))
        
        let e = Piece(playerTwo, Position(0,2))
        let f = Piece(playerTwo, Position(2,0))
        let g = Piece(playerTwo, Position(4,2))
        let h = Piece(playerTwo, Position(2,4))
        
        let x = Piece(playerTwo, Position(2,2))
        
        board.add(a)
        board.add(e)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 1, "One matching position")
        board.add(b)
        board.add(f)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 2, "Two matching positions")
        board.add(c)
        board.add(h)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 3, "Three matching positions")
        board.add(d)
        board.add(g)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 4, "Four matching positions")
        let pieces = board.piecesTrappedBy(x)
        XCTAssert(pieces[0].player == playerOne, "0 is player 2")
        XCTAssert(pieces[1].player == playerOne, "1 is player 2")
        XCTAssert(pieces[2].player == playerOne, "2 is player 2")
        XCTAssert(pieces[3].player == playerOne, "3 is player 2")
    }
    func testRemoveJumps() {
        // Assert which pieces are removed
        
    }
    func testPiecesCannotBePlaced() {
        // Assert which pieces are removed
        
    }
}
