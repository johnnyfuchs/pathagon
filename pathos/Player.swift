//
//  Player.swift
//  pathos
//
//  Created by Johnny Sparks on 10/1/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import Foundation

public func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.color == rhs.color
}

public class Player:Equatable {
    
    let startingPieces = 14
    
    var name:String
    var color:PlayerColor
    var pieces:[Piece] = []
    
    init(name:String, color:PlayerColor){
        self.name = name
        self.color = color
        
        for _ in 0...startingPieces {
            pieces.append(Piece(player: self))
        }
    }
    
    func drawPiece() -> Piece? {
        if pieces.count > 0 {
            let piece = pieces[0]
            pieces.removeAtIndex(0)
            return piece
        }
        return nil
    }
    
    func description() -> String {
        return "name: \(name) side: \(color.description())"
    }
}