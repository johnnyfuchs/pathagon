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
        let playerOne:Player = .White
        let playerTwo:Player = .Black
        let board = Board(size: 7)
        let a = Piece(playerOne, Position(1,2))
        let b = Piece(playerOne, Position(2,1))
        let c = Piece(playerOne, Position(2,3))
        let d = Piece(playerOne, Position(3,2))
        
        let e = Piece(playerTwo, Position(0,2))
        let f = Piece(playerTwo, Position(2,0))
        let g = Piece(playerTwo, Position(4,2))
        let h = Piece(playerTwo, Position(2,4))
        
        let x = Piece(playerTwo, Position(2,2))
        
        board.play(a)
        board.play(e)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 1, "One matching position")
        board.play(b)
        board.play(f)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 2, "Two matching positions")
        board.play(c)
        board.play(h)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 3, "Three matching positions")
        board.play(d)
        board.play(g)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 4, "Four matching positions")
        let pieces = board.piecesTrappedBy(x)
        XCTAssert(pieces[0].player == playerOne, "0 is player 2")
        XCTAssert(pieces[1].player == playerOne, "1 is player 2")
        XCTAssert(pieces[2].player == playerOne, "2 is player 2")
        XCTAssert(pieces[3].player == playerOne, "3 is player 2")
    }
    
    func testRemoveJumps() {

        let board = Board(size: 7)
        let a = Piece(.White, Position(1,2))
        let b = Piece(.White, Position(2,1))
        let c = Piece(.White, Position(2,3))
        let d = Piece(.White, Position(3,2))
        
        let e = Piece(.Black, Position(0,2))
        let f = Piece(.Black, Position(2,0))
        let g = Piece(.Black, Position(4,2))
        let h = Piece(.Black, Position(2,4))
        
        let x = Piece(.Black, Position(2,2))
        
        board.play(a)
        board.play(e)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 1, "One matching position")
        board.play(b)
        board.play(f)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 2, "Two matching positions")
        board.play(c)
        board.play(h)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 3, "Three matching positions")
        board.play(d)
        board.play(g)
        XCTAssertEqual(board.piecesTrappedBy(x).count, 4, "Four matching positions")
        let pieces = board.piecesTrappedBy(x)
        println(pieces)
        println(board)
        XCTAssert(pieces[0].player == .White, "0 is player 2")
        XCTAssert(pieces[1].player == .White, "1 is player 2")
        XCTAssert(pieces[2].player == .White, "2 is player 2")
        XCTAssert(pieces[3].player == .White, "3 is player 2")
    }
    
    func testPiecesCannotBePlaced() {
        // Assert which pieces are removed
        let board = Board(size: 7)
        
        let pa = Position(1,2)
        let pb = Position(2,1)
        
        let a = Piece(.White, pa)
        let b = Piece(.White, pb)
        
        board.play(a)

        XCTAssertFalse( board.canPlay(a), "Can't add a piece over another piece")
        XCTAssertTrue( board.canPlay(b), "Can add a piece over fresh square")
    }
    
    func testTrappedPiecesAreRemoved() {
        let board = Board(size: 7)
        
        let a = Piece(.White, Position(1,2))
        let b = Piece(.White, Position(2,1))
        let c = Piece(.White, Position(2,3))
        let d = Piece(.White, Position(3,2))
        
        let e = Piece(.Black, Position(0,2))
        let f = Piece(.Black, Position(2,0))
        let g = Piece(.Black, Position(4,2))
        let h = Piece(.Black, Position(2,4))
        
        let x = Piece(.Black, Position(2,2))
        
        board.play(a)
        board.play(b)
        board.play(c)
        board.play(d)
        board.play(e)
        board.play(f)
        board.play(g)
        board.play(h)
        
        XCTAssertFalse( board.canPlay(a), "Can't add a piece in a previously filled position")
        XCTAssertFalse( board.canPlay(b), "Can't add a piece in a previously filled position")
    }
    
    func testPiecesLeft() {

        let board = Board(size: 7)
        
        let a = Piece(.White, Position(1,2))
        let b = Piece(.White, Position(2,1))
        let c = Piece(.White, Position(2,3))
        let d = Piece(.White, Position(3,2))
        
        let e = Piece(.Black, Position(0,2))
        let f = Piece(.Black, Position(2,0))
        let g = Piece(.Black, Position(4,2))
        let h = Piece(.Black, Position(2,4))
        
        let x = Piece(.Black, Position(2,2))
        
        board.play(a)
        XCTAssertEqual( board.piecesLeftForPlayer(.White), board.piecesPerPlayer - 1, "remaining pieces")
        board.play(b)
        XCTAssertEqual( board.piecesLeftForPlayer(.White), board.piecesPerPlayer - 2, "remaining pieces")
        board.play(c)
        XCTAssertEqual( board.piecesLeftForPlayer(.White), board.piecesPerPlayer - 3, "remaining pieces")
        board.play(d)
        XCTAssertEqual( board.piecesLeftForPlayer(.White), board.piecesPerPlayer - 4, "remaining pieces")
        board.play(e)
         XCTAssertEqual( board.piecesLeftForPlayer(.Black), board.piecesPerPlayer - 1, "remaining pieces")
        board.play(f)
         XCTAssertEqual( board.piecesLeftForPlayer(.Black), board.piecesPerPlayer - 2, "remaining pieces")
        board.play(g)
         XCTAssertEqual( board.piecesLeftForPlayer(.Black), board.piecesPerPlayer - 3, "remaining pieces")
        board.play(h)
         XCTAssertEqual( board.piecesLeftForPlayer(.Black), board.piecesPerPlayer - 4, "remaining pieces")
        board.play(x)
        XCTAssertEqual( board.piecesLeftForPlayer(.White), board.piecesPerPlayer, "resets remaining pieces")
    }
    
    func testWinExists() {
        let board = Board(size: 4)
        let a = Piece(.White, Position(0,0))
        board.play(a)
                println(board)
        XCTAssertFalse(board.winExistsFor(.White), "No win")
        let b = Piece(.White, Position(3,0))
        board.play(b)
        println(board)
        XCTAssertFalse(board.winExistsFor(.White), "No win")
        let c = Piece(.White, Position(3,1))

        board.play(c)
                println(board)
        XCTAssertFalse(board.winExistsFor(.White), "No win")
        let d = Piece(.White, Position(3,2))
        board.play(d)
                println(board)
        XCTAssertFalse(board.winExistsFor(.White), "No win")
        let e = Piece(.White, Position(2,2))
        board.play(e)
                println(board)
        XCTAssertFalse(board.winExistsFor(.White), "No win")
        let f = Piece(.White, Position(2,3))
        board.play(f)
                println(board)
        XCTAssertTrue(board.winExistsFor(.White), "We have a winner!")
    }
    
    func testBoardGridAddPieceAt() {
        var board = BoardGrid()
        board.add(Piece(.White, Position(0,0)))
        board.add(Piece(.White, Position(0,1)))
        XCTAssert(board.pieceAt(Position(0,0)) != nil, "piece exists")
        XCTAssert(board.pieceAt(Position(0,1)) != nil, "piece exists")
    }
    
    func testBoardGridAddPieces() {
        var board = BoardGrid()
        board.add(Piece(.White, Position(1,0)))
        board.add(Piece(.White, Position(0,1)))
        board.add(Piece(.White, Position(1,6)))
        board.add(Piece(.White, Position(4,2)))
        board.add(Piece(.White, Position(4,5)))
        board.add(Piece(.Black, Position(2,2)))
        board.add(Piece(.Black, Position(1,2)))
        board.add(Piece(.Black, Position(3,3)))
        board.add(Piece(.Black, Position(5,6)))
        board.add(Piece(.Black, Position(6,6)))
        XCTAssertEqual( board.allPieces().count, 10 , "has appropriate piece count")
    }
    
    func testDoesntReAddPieces() {
        var board = BoardGrid()
        board.add(Piece(.White, Position(4,1)))
        board.add(Piece(.White, Position(4,1)))
        board.add(Piece(.Black, Position(3,7)))
        board.add(Piece(.Black, Position(3,7)))
        XCTAssertEqual( board.allPieces().count, 2 , "has appropriate piece count")
    }
    func testRemovesPieces() {
        var board = BoardGrid()
        board.add(Piece(.White, Position(4,1)))
        board.add(Piece(.White, Position(4,2)))
        board.add(Piece(.Black, Position(3,1)))
        board.add(Piece(.Black, Position(3,6)))
        board.remove(Piece(.White, Position(4,2)))
        board.remove(Piece(.Black, Position(3,6)))
        XCTAssertEqual( board.allPieces().count, 2 , "has appropriate piece count")
    }
    
    func testHighlightsAPiece() {
        var board = BoardGrid()
        let piece = Piece(.White, Position(4,1))
        board.add(piece)
        board.highlight(piece.position)
        XCTAssert(board.highlighted() != nil, "highlights a piece")
        board.unhighlight()
        XCTAssert(board.highlighted() == nil, "unhighlights a piece")
    }
}
