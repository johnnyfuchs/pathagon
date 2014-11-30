//
//  RootViewController.swift
//  pathos
//
//  Created by Johnny Sparks on 7/19/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

import Foundation
import UIKit
import Darwin

public func == (lhs:Position, rhs:Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func !== (lhs:Position, rhs:Position) -> Bool {
    return !(lhs == rhs)
}

public func + (lhs:Position, rhs:Position) -> Position {
    return Position(lhs.x + rhs.x, lhs.y + rhs.y)
}

public struct Position:Equatable {
    public var x, y :Int
    
    func description() -> String {
        return "{ x:\(x) y:\(y) }"
    }
    
    public init(_ x:Int,_ y:Int){
        self.x = x
        self.y = y
    }
}

public enum Direction {
    case N, NE, E, SE, S, SW, W, NW
    
    public func toCoord() -> Position {
        switch self {
            case .N:  return Position(0, -1)
            case .NE: return Position(1, -1)
            case .E:  return Position(1 , 0)
            case .SE: return Position(1 , 1)
            case .S:  return Position(0 , 1)
            case .SW: return Position(1, -1)
            case .W:  return Position(-1 ,0)
            case .NW: return Position(-1,-1)
        }
    }
}

public func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.name == rhs.name
}

public func !== (lhs: Player, rhs: Player) -> Bool {
    return !(lhs.name == rhs.name)
}

public class Player:Equatable {
    
    public var name:String
    
    public init(name:String){
        self.name = name
    }
    
    func description() -> String {
        return "name: \(name)"
    }
}

public func == (lhs: Piece, rhs: Piece) -> Bool {
    return lhs.position! == rhs.position! && lhs.player == rhs.player;
}

public func !== (lhs:Piece, rhs:Piece) -> Bool {
    return !(lhs == rhs)
}
    
public class Piece : Printable, Equatable {
    public var position:Position?
    public var player:Player
    public var highlight:Bool = false
    
    public init(player:Player){
        self.player = player
    }
    
    public init(_ player:Player, _ position:Position){
        self.player = player
        self.position = position
    }
    
    public var description : String {
        return "player: {\(player.description())}, position: \(position?.description())"
    }
}

public class Move {
    public var piece:Piece
    var to:Position
    
    public init(piece:Piece, to:Position){
        self.piece = piece
        self.to = to
    }
    
    public func complete(){
        piece.position = to
    }
    
    func description() -> String {
        return "piece: \(piece),\n target: \(to.description())"
    }
}

public class Game {
    public var board:Board
    public var players:[Player]
    public var turn:Player
    
    public init(board:Board){
        self.board = board
        
        players = [
            Player(name: "Hey"),
            Player(name: "You")
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
        
        if !move.piece.highlight {
            
            board.add(move.piece)
            
            let trappedPieces = board.piecesTrappedBy(move.piece)
            board.removePieces(trappedPieces)
            
        } else {
            move.piece.highlight = false
        }
        
        return true
    }
}

public class Board {
    
    var size = 8
    var pieces:[Piece] = []
    var removedPieces:[Piece] = []
    let goals:[Direction] = [.N, .S, .E, .W]
    
    public init(size:Int){
        self.size = size;
    }
    
    public func add(piece:Piece) {
        pieces.append(piece)
    }
    
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
        for piece in pieces {
            if piece.position! == position {
                return piece
            }
        }
        return nil
    }
    
    public func piecesTrappedBy(piece:Piece) -> [Piece] {
        let player = piece.player
        var matches:[Piece] = []
        let dirs:[Direction] = [.N, .S, .E, .W]
        if let pos = piece.position {
            for d in dirs {
                if let captureable = pieceAt(pos + d.toCoord()) {
                    if captureable.player !== player {
                        if let trapping = pieceAt(pos + d.toCoord() + d.toCoord()) {
                            if trapping.player == player {
                                matches.append(captureable)
                            }
                        }
                    }
                }
            }
        }
        return matches
    }
    
    func removePieces(piecesToRemove:[Piece]) {
        pieces = pieces.filter { (piece) -> Bool in
            for pieceToRemove in piecesToRemove {
                if piece === pieceToRemove {
                    return false
                }
            }
            return true
        }
        removedPieces = piecesToRemove
    }
}

class BoardView: UIView {
    var game:Game
    
    var onTileTapped:(pos:Position) -> ()
    
    // local vars
    var tileViews:[[UIView]] = []
    var tapRecognizer:UITapGestureRecognizer?

    init(frame: CGRect, game:Game){
        self.game = game
        
        for row in 0...game.board.size {
            
            var tileRowViews:[UIView] = []
            
            for col in 0...game.board.size {
                var tileView = UIView(frame: CGRectZero)
                tileRowViews.append(tileView)
            }

            tileViews.append(tileRowViews)
        }
        
        self.onTileTapped = {(pos:Position) in }
        
        super.init(frame: frame)
        
        userInteractionEnabled = true
        clipsToBounds = true
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        addGestureRecognizer(tapRecognizer!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func handleTap(sender: UITapGestureRecognizer){
        let point = sender.locationInView(self)
        let col = Int(floor((point.x / frame.width) * CGFloat(game.board.size)))
        let row = Int(floor((point.y / frame.height) * CGFloat(game.board.size)))
        self.onTileTapped(pos:Position(col, row))
    }
    
    func render() {

        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        drawBoard()
        drawPieces()
    }
    
    func drawPieces(){
        for p in game.board.pieces {
            draw(p)
        }
    }
    
    func draw(piece:Piece){
        if let p = piece.position {
            if let pos = piece.position {
                let frame = rectForTileAt(pos.y, pos.x)
                let pieceView = UIView(frame: frame)
                pieceView.layer.cornerRadius = frame.width / 2.0
                pieceView.backgroundColor = piece.player == game.players[0] ? UIColor.orangeColor() : UIColor.magentaColor()
                if piece.highlight {
                    pieceView.backgroundColor = UIColor.yellowColor()
                }
                self.addSubview(pieceView)
            }
        }
    }
    
    func rectForTileAt(row:Int, _ col:Int) -> CGRect {
        let size = tileSize()
        return CGRectMake(CGFloat(col) * size.width, CGFloat(row) * size.height, size.width, size.height)
    }
    
    func tileSize() -> CGSize {
        let w = frame.size.width / CGFloat(game.board.size)
        let h = frame.size.height / CGFloat(game.board.size)
        
        return CGSize(width: w, height: h)
    }
    
    func drawBoard(){
        var columns = game.board.size
        var rows = game.board.size
        
        let size = tileSize()
        let w = size.width
        let h = size.height
        
        for row:Int in 0...rows {
            for col:Int in 0...columns {
                tileViews[row][col].frame = rectForTileAt(row, col)
                tileViews[row][col].backgroundColor = colorAt(row, col)
            }
        }
        
        for tileRowViews in tileViews {
            for tileView in tileRowViews {
                self.addSubview(tileView)
            }
        }
    }
    
    func colorAt( row:Int, _ col:Int) -> UIColor {
        return ((row % 2 == 0) && !(col % 2 == 0)) || (!(row % 2 == 0) && (col % 2 == 0)) ? UIColor.whiteColor() : UIColor.lightGrayColor()
    }
}

class RootViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let board = Board(size: 7)
        
        let game = Game(board: board)
        
        var boardView = BoardView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.width), game: game)
        view.addSubview(boardView)
        
        boardView.render()
        boardView.onTileTapped = { (pos:Position) in

            if let piece = game.board.pieceAt(pos) {
                if let highlightedPiece = board.highlightedPiece() {
                    if piece == highlightedPiece {
                         piece.highlight = false
                    }
                }
                else {
                    piece.highlight = piece.player == game.turn
                }
            }
            
            else {
                
                var move = Move(piece: Piece(player: game.turn), to: pos)
                
                if let highlightedPiece = board.highlightedPiece() {
                    move = Move(piece: highlightedPiece, to: pos)
                }
                
                if game.playMove(move) {
                    game.turn = game.nextPlayer()
                }
                
                println(move.description())
            }

            
            boardView.render()
        }
    }
}