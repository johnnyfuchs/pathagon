//
//  Board.swift
//  pathos
//
//  Created by Johnny Sparks on 9/27/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import Foundation


public class Board {
    
    public let size = 8
    var pieces:[Piece] = []
    let goals:[Direction] = [.N, .S, .E, .W]
    
    public init(){ }
    
    func highlightedPiece() -> Piece? {
        for piece in pieces {
            if piece.highlight {
                return piece
            }
        }
        return nil
    }
    
    func isValidMove(move:Move) -> Bool {
        for piece in pieces {
            if move.to.x == piece.position?.x && move.to.y == piece.position?.y {
                return false
            }
        }
        
        return move.to.x >= 0 && move.to.x < size && move.to.y >= 0 && move.to.y < size
    }
    
    func pieceAt(position:Position) -> Piece? {
        for piece:Piece in pieces {
            if piece.position! == position {
                return piece
            }
        }
        return nil
    }
    
    func piecesFrom(point:Position, directions:[Direction]) -> [Piece] {
        var matches:[Piece] = []
        for piece in pieces {
            for direction in directions {
                if let match = pieceFrom(point, direction: direction) {
                    matches.append(match)
                }
            }
        }
        return matches
    }
    
    func pieceFrom(point:Position, direction:Direction) -> Piece? {
        return pieceAt(point + direction.toCoord())
    }
}
