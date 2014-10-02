//
//  Game.swift
//  pathos
//
//  Created by Johnny Sparks on 9/27/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import Foundation

public class Game {
    public var board:Board
    public var players:[Player]
    var turn:Player
    
    public init(board:Board){
        self.board = board
        
        players = [
            Player(name: "Hey", color: PlayerColor.White),
            Player(name: "You", color: PlayerColor.Black)
        ]
        
        turn = players[0]
    }
    
    func nextPlayer() -> Player {
        return turn == players[0] ? players[1] : players[0]
    }
    
    func playMove(move:Move) -> Bool {
        
        if !board.isValidMove(move) {
            return false
        }
        
        move.complete()
        println(move.piece.position?.description())
        if !move.piece.highlight {
            board.pieces.append(move.piece)
        } else {
            move.piece.highlight = false
        }
        
        println(board.pieces.count)
        
        return true
    }
    
}