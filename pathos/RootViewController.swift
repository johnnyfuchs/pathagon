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


func == (lhs:Position, rhs:Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

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

enum PlayerColor {
    case White, Black
    
    func description() -> String {
        switch self {
        case .White:
                return "White"
        case .Black:
                return "Black"
        }
    }
    
    func string(type:String) -> PlayerColor {
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



func == (lhs: Piece, rhs: Piece) -> Bool {
    return lhs.position! == rhs.position! && lhs.player == rhs.player;
}
    
class Piece {
    var position:Position?
    var player:Player
    var highlight:Bool = false
    
    init(player:Player){
        self.player = player
    }
    
    func description() -> String {
        return "player: {\(player.description())}, position: \(position?.description())"
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
        piece.position = to
    }
    
    func description() -> String {
        return "piece: \(piece.description()),\n target: \(to.description())"
    }
}

class Path {
    var pieces:[Piece] = []
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
                pieceView.backgroundColor = piece.player.color == .Black ? UIColor.orangeColor() : UIColor.magentaColor()
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
        
        let board = Board()
        
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