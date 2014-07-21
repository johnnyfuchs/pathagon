//
//  RootViewController.swift
//  pathos
//
//  Created by Johnny Sparks on 7/19/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

// TODO: Come up with a "Turn" system


import Foundation
import UIKit
import Darwin


func + (lhs:Position, rhs:Position) -> Position {
    return Position(lhs.x + rhs.x, lhs.y + lhs.y)
}


struct Position {
    var x, y :Int
    
    func description() -> String {
        return "x:\(x) y:\(y)"
    }
    init(_ x:Int,_ y:Int){
        self.x = x
        self.y = y
    }
}

enum Direction {
    case N, NE, E, SE, S, SW, W, NW
    
    func toCoord() -> Position {
        switch self {
            case .N:  return Position(-1, 0)
            case .NE: return Position(-1, 1)
            case .E:  return Position(0 , 1)
            case .SE: return Position(1 , 1)
            case .S:  return Position(0 , 1)
            case .SW: return Position(-1, 1)
            case .W:  return Position(0 ,-1)
            case .NW: return Position(-1,-1)
        }
    }
}

enum PlayerType {
    case White, Black
    
    func description() -> String {
        switch self {
        case .White:
                return "White"
        case .Black:
                return "Black"
        }
    }
    
    func string(type:String) -> PlayerType {
        switch type {
            case "White":
                return White
            case "Black":
                return Black
            default:
                return White
        }
    }
}


func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.type == rhs.type
}

class Player:Equatable {
    
    let startingPieces = 14
    
    var name:String
    var type:PlayerType
    var pieces:[Piece] = []
    
    init(name:String, type:PlayerType){
        self.name = name
        self.type = type
        
        println(type.description())
        
        for _ in 0...startingPieces {
            pieces += Piece(player: self)
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
        return "name: \(name) side: \(type.description())"
    }
}

enum TurnAction {
    case BeginTurn, PlayPiece, PickupPiece, EndTurn, InvalidMove, Win, Lose
}

class Piece {
    var lastPosition:Position?
    var position:Position?
    var player:Player
    
    init(player:Player){
        self.player = player
    }
    
    func moveTo(pos:Position) {
        self.lastPosition = self.position
        self.position = pos
    }
    
    func description() -> String {
        return "player: {\(player.description())}, position: \(position?.description()), lastPosition: \(lastPosition?.description())"
    }
}

class Move {
    var piece:Piece
    var to:Position
    
    init(piece:Piece, to:Position){
        self.piece = piece
        self.to = to
    }
    
    func complete(){
        piece.moveTo(to)
    }
    
    func description() -> String {
        return "piece: \(piece.description()),\n lastPosition: \(to.description())"
    }
}


class Game {
    var board:Board
    var moves:[Move] = []
    var players:[Player]
    var turn:Player
    
    
    init(board:Board, players:[Player]){
        self.board = board
        self.players = players
        turn = players[0]
    }
    
    func attemptTurnAction(action:TurnAction, player:Player){
        
    }
    
    func attemptMove(move:Move){
        if !board.isValidMove(move) {        }
        
        move.complete()

    }
    
    func nextPlayerAction() -> (player:Player, action:TurnAction) {
        let next = turn == players[0] ? players[1] : players[0]
        turn = next
        return (next, .EndTurn)
    }
}

class Board {
    
    var rows = 8
    var columns = 8
    var pieces:[Piece] = []
    
    init(rows :Int, columns:Int){
        self.columns = columns;
        self.rows = rows
    }
    
    func isValidMove(move:Move) -> Bool {
        
        for piece in pieces {
            if move.to.x == piece.position?.x && move.to.y == piece.position?.y {
                return false
            }
        }
        
        return move.to.x >= 0 && move.to.x < columns && move.to.y >= 0 && move.to.y < rows
    }
    
    func piecesFrom(point:Point, inDirections:[Direction]) -> [Piece] {
        return [Piece(player: Player(name: "as", type: .White))]
    }
    
    func pieceFrom(point:Point, dir:Direction) -> Piece? {
        
        return Piece(player: Player(name: "as", type: .White))
    }
}


class BoardView: UIView {
    var game:Game
    
    var onTileTapped:(pos:Position) -> ()
    
    // local vars
    var tileViews:Array<Array<UIView>> = []
    var tapRecognizer:UITapGestureRecognizer?

    init(frame: CGRect, game:Game){
        self.game = game
        
        for row in 0...game.board.rows {
            
            var tileRowViews:Array<UIView> = []
            
            for col in 0...game.board.columns {
                var tileView = UIView(frame: CGRectZero)
                tileRowViews += tileView
            }

            tileViews += tileRowViews
        }
        
        self.onTileTapped = {(pos:Position) in }
        
        super.init(frame: frame)
        
        userInteractionEnabled = true
        clipsToBounds = true
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        addGestureRecognizer(tapRecognizer)
        
        for tileRowViews in tileViews {
            for tileView in tileRowViews {
                self.addSubview(tileView)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    
    
    func handleTap(sender: UITapGestureRecognizer){
        let point = sender.locationInView(self)
        let col = Int(floor((point.x / frame.width) * CGFloat(game.board.columns)))
        let row = Int(floor((point.y / frame.height) * CGFloat(game.board.rows)))
        self.onTileTapped(pos:Position(col, row))
    }
    
    func render() {
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
                pieceView.backgroundColor = piece.player.type == .Black ? UIColor.orangeColor() : UIColor.magentaColor()
                self.addSubview(pieceView)
            }
        }
    }
    
    func rectForTileAt(row:Int, _ col:Int) -> CGRect {
        let size = tileSize()
        return CGRectMake(CGFloat(col) * size.width, CGFloat(row) * size.height, size.width, size.height)
    }
    
    func tileSize() -> CGSize {
        let w = frame.size.width / CGFloat(game.board.columns)
        let h = frame.size.height / CGFloat(game.board.rows)
        
        return CGSize(width: w, height: h)
    }
    
    func drawBoard(){
        var columns = game.board.columns
        var rows = game.board.rows
        
        let size = tileSize()
        let w = size.width
        let h = size.height
        
        for row:Int in 0...rows {
            for col:Int in 0...columns {
                tileViews[row][col].frame = rectForTileAt(row, col)
                tileViews[row][col].backgroundColor = colorAt(row, col)
            }
        }
    }
    
    func colorAt( row:Int, _ col:Int) -> UIColor {
        return ((row % 2 == 0) && !(col % 2 == 0)) || (!(row % 2 == 0) && (col % 2 == 0)) ? UIColor.whiteColor() : UIColor.lightGrayColor()
    }
    
    func afterMove(move:Move) {
        
        // check for victory
        
        // remove sandwiched pieces
        
    }
    
    
}

class RootViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let playerA = Player(name: "A", type: PlayerType.Black)
        let playerB = Player(name: "B", type: PlayerType.White)
     
        let board = Board(rows: 8, columns: 8)
        
        let game = Game(board: board, players: [playerA, playerB])
        
        var boardView = BoardView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.width), game: game)
        view.addSubview(boardView)
        
        boardView.onTileTapped = { (pos:Position) in
            
            var num:Int? = "cat".toInt()?
            
            if let knownNum = num {
                knownNum + 10
            }
            
            
            
            // if the player still has pieces
            if game.turn.pieces.count > 0 {
                
                if let piece = game.turn.drawPiece() {
//                    let move = Move(player: game.turn, piece: piece, to: Position(pos.x, pos.y))
//                    game.attemptMove(move)
//                    boardView.render()
                }
            }

        }
    }
}