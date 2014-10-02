//
//  pathosTests.swift
//  pathosTests
//
//  Created by Johnny Sparks on 7/18/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import XCTest
import pathos

class GameRules: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGameHasAn8x8Board() {
        var game = Game(board: Board())
        
        XCTAssert(game.board.size == 8 , "Board has a size of 8")
    }

    func testGameHasTwoPlayers() {
        var game = Game(board: Board())
        
        XCTAssert(game.players.count == 2, "A game has two players")
    }
    
    func testGameHasTwoPlayers() {
        var game = Game(board: Board())
        
        XCTAssert(game.players.count == 2, "A game has two players")
    }
}
