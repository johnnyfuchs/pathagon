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


struct Position {
    var x, y :Int
    
    func description() -> String {
        return "x:\(x) y:\(y)"
    }
}

enum PlayerType {
    case White
    case Black
    
    func description() -> String {
        switch self {
        case .White:
                return "White"
        case .Black:
                return "Black"
        }
    }
}


func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.type == rhs.type
}

class Player:Equatable {
    var name:String
    var type:PlayerType
    
    init(name:String, type:PlayerType){
        self.name = name
        self.type = type
    }
    
    func description() -> String {
        return "name:\(name) y:\(type.description())"
    }
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
    
    var player:Player
    var piece:Piece
    var to:Position
    
    init(player:Player, piece:Piece, to:Position){
        self.player = player
        self.piece = piece
        self.to = to
    }
    
    func complete(){
        piece.moveTo(to)
    }
    
    func description() -> String {
        return "player: {\(player.description())}, piece: \(piece.description()), lastPosition: \(to.description())"
    }
}


class Game {
    var board:Board
    var moves:[Move] = []
    var players:[Player]
    var turn:Player
    
    init(board:Board, players:Array<Player>){
        self.board = board
        self.players = players
        turn = players[0]
    }
    
    func makeMove(move:Move) -> Bool {

        if isValidMove(move) {
            move.complete()
            moves += move
            return true
        }
        return false
    }
    
    func isValidMove(move:Move) -> Bool {
        
        for piece in board.pieces {
            if move.to.x == piece.position?.x || move.to.y == piece.position?.y {
                return false
            }
        }
        
        return move.to.x >= 0 && move.to.x < board.columns && move.to.y >= 0 && move.to.y < board.rows
    }
    
    func nextTurn() -> Player {
        let next = turn == players[0] ? players[1] : players[0]
        turn = next
        return next
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
}


class BoardView: UIView {
    var game:Game
    
    var onTileTapped:(col:Int, row:Int) -> ()
    
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
        
        self.onTileTapped = {(col:Int, row:Int) in }
        
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
        drawBoard()
        drawPieces()
        super.layoutSubviews()
    }
    
    
    func handleTap(sender: UITapGestureRecognizer){
        let point = sender.locationInView(self)
        let col = Int(floor((point.x / frame.width) * CGFloat(game.board.columns)))
        let row = Int(floor((point.y / frame.height) * CGFloat(game.board.rows)))
        self.onTileTapped(col: col, row: row)
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
                pieceView.backgroundColor = UIColor.orangeColor()
                self.addSubview(pieceView)
            }
        }
    }
    
    func rectForTileAt(column:Int, _ row:Int) -> CGRect {
        let size = tileSize()
        return CGRectMake(CGFloat(column) * size.width, CGFloat(row) * size.height, size.width, size.height)
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
                tileViews[row][col].frame = rectForTileAt(col, row)
                tileViews[row][col].backgroundColor = colorAt(row, col)
            }
        }
    }
    
    func colorAt( row:Int, _ col:Int) -> UIColor {
        return ((row % 2 == 0) && !(col % 2 == 0)) || (!(row % 2 == 0) && (col % 2 == 0)) ? UIColor.whiteColor() : UIColor.blackColor()
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
        
        boardView.onTileTapped = { (col:Int, row:Int) in
            
            let player = game.nextTurn()
            let piece = Piece(player: player)
            let move = Move(player: player, piece: piece, to: Position(x: col, y: row))
            game.makeMove(move)
            boardView.layoutSubviews()
        }
    }
}