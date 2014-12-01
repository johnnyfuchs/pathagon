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

public struct Position:Equatable, Hashable {
    public var x, y :Int
    
    public var hashValue:Int {
        return x.hashValue ^ y.hashValue
    }
    
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

public class Player:Equatable, Hashable {
    
    public var hashValue: Int {
        return name.hashValue
    }
    
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
    
public class Piece : Printable, Equatable, Hashable {
    public var position:Position?
    public var player:Player
    public var highlighted:Bool = false
    public var hashValue: Int {
        return player.hashValue ^ position!.hashValue
    }
    
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

public class Board: Printable {
    
    var size = 8
    public let piecesPerPlayer = 14
    var pieces:[Piece] = []
    var removedPieces:[Piece] = []
    let goals:[Direction] = [.N, .S, .E, .W]
    public let playerA:Player
    public let playerB:Player
    var lastPiece:Piece?
    public var description:String {
        var o = "---------------\n"
        for row in 0...size-1 {
            o += "|"
            for col in 0...size-1 {
                if let piece = pieceAt(Position(col, row)) {
                    o += piece.player == playerA ? "A" : "B"
                } else {
                    o += " "
                }
            }
            o += "|\n"
        }
        o += "---------------"
        return o
    }
    
    public init(size:Int, a:Player, b:Player){
        self.size = size
        playerA = a
        playerB = b
    }
    
    public func currentPlayer() -> Player {
        if let lastPlayer = lastPiece?.player {
            if lastPlayer == playerA {
                return playerB
            }
        }
        return playerA
    }
    
    public func move(from:Position, to:Position) -> Bool {
        if let piece = pieceAt(from) {
            if canPlay(Piece(piece.player, to)) {
                piece.position = to
                completeMove(piece)
                return true
            }
        }
        return false
    }
    
    public func play(piece:Piece) -> Bool {
        if canPlay(piece) {
            pieces.append(piece)
            completeMove(piece)
            return true
        }
        return true
    }
    
    public func canPlay(targetPiece:Piece) -> Bool {
        for piece in pieces {
            if piece.position == targetPiece.position? {
                return false
            }
        }
        for piece in removedPieces {
            if piece.position == targetPiece.position? {
                return false
            }
        }
        
        let pos = targetPiece.position!
        
        return pos.x >= 0 && pos.x < size && pos.y >= 0 && pos.y < size
    }
    
    func highlight(piece pieceToHighlight:Piece, highlight:Bool){
        for piece in pieces {
            piece.highlighted = false
        }
        if !highlight {
            return
        }
        if let pos = pieceToHighlight.position {
            if let targetPiece = pieceAt(pos) {
                targetPiece.highlighted = true
            }
        }
    }
    
    func highlightedPiece() -> Piece? {
        for piece in pieces {
            if piece.highlighted {
                return piece
            }
        }
        return nil
    }
    
    func completeMove(piece:Piece) {
        piece.highlighted = false
        lastPiece = piece
        let trappedPieces = piecesTrappedBy(piece)
        removePieces(trappedPieces)
        removedPieces = trappedPieces
    }
    
    public func pieceAt(position:Position) -> Piece? {
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
    
    public func removePieces(piecesToRemove:[Piece]) {
        pieces = pieces.filter { (piece) -> Bool in
            for pieceToRemove in piecesToRemove {
                if piece === pieceToRemove {
                    return false
                }
            }
            return true
        }
    }
    
    public func piecesLeftForPlayer(player:Player) -> Int {
        var playedPieces = 0
        for piece in pieces {
            if piece.player == player {
                playedPieces++
            }
        }
        return piecesPerPlayer - playedPieces
    }
    
    public func winExistsFor(player:Player) -> Bool {
        
        var startNodes:[Piece] = player == playerA ? piecesInRow(0) : piecesInCol(0)
        var endNodes:[Piece] = player == playerA ? piecesInRow(size - 1) : piecesInCol(size - 1)
        
        if !(startNodes.count > 0 && endNodes.count > 0) {
            println("no nodes to work with")
            return false
        } else {
            for start in startNodes {
                for end in endNodes {
                    if pathExists(self, start, end) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func piecesInRow(row:Int) -> [Piece] {
        var rowPieces:[Piece] = []
        for piece in pieces {
            if piece.position!.y == row {
                rowPieces.append(piece)
            }
        }
        return rowPieces
    }
    
    func piecesInCol(col:Int) -> [Piece] {
        var colPieces:[Piece] = []
        for piece in pieces {
            if piece.position!.x == col {
                colPieces.append(piece)
            }
        }
        return colPieces
    }
}


func pathExists(board:Board, start:Piece, end:Piece) -> Bool {
    
    func heuristic(a:Position, b:Position) -> Int {
        return abs(a.x - b.x) + abs(a.y - b.y)
    }
    
    func neigbors(board:Board, position:Position) -> [Piece] {
        var pieces:[Piece] = []
        let dirs:[Direction] = [.N, .E, .S, .W]
        for dir in dirs {
            if let piece = board.pieceAt(position + dir.toCoord()){
                pieces.append(piece)
            }
        }
        return pieces
    }
    
    var frontier = PriorityQueue<Int, Piece>()
    frontier.push(0, item: start)
    var path = Dictionary<Piece, Piece>()
    var costs = Dictionary<Piece, Int>()
    
    while !frontier.empty() {
        let current = frontier.pop()!.1
        
        if current == end {
            return true
        }
        
        let neighbors = neigbors(board, current.position!)
        for neighbor in neighbors {
            let newCost = costs[current] ?? 0 + heuristic(neighbor.position!, end.position!)
            
            if costs[neighbor] == nil || newCost < (costs[neighbor] ?? 0) {
                costs[neighbor] = newCost
                let priority = newCost + heuristic(neighbor.position!, end.position!)
                frontier.push(priority, item: neighbor)
                path[neighbor] = current
            }
        }
    }
    
    return false
}

//frontier = PriorityQueue()
//frontier.put(start, 0)
//came_from = {}
//cost_so_far = {}
//came_from[start] = None
//cost_so_far[start] = 0
//
//while not frontier.empty():
//  current = frontier.get()
//
//  if current == goal:
//    break
//
//  for next in graph.neighbors(current):
//    new_cost = cost_so_far[current] + graph.cost(current, next)
//    if next not in cost_so_far or new_cost < cost_so_far[next]:
//      cost_so_far[next] = new_cost
//      priority = new_cost + heuristic(goal, next)
//      frontier.put(next, priority)
//      came_from[next] = current



class BoardView: UIView {
    var board:Board
    var onTileTapped:(pos:Position) -> ()
    var tileViews:[[UIView]] = []
    var tapRecognizer:UITapGestureRecognizer?

    init(frame: CGRect, board:Board){
        self.board = board
        for row in 0...board.size {
            var tileRowViews:[UIView] = []
            for col in 0...board.size {
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
        let col = Int(floor((point.x / frame.width) * CGFloat(board.size)))
        let row = Int(floor((point.y / frame.height) * CGFloat(board.size)))
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
        for p in board.pieces {
            draw(p)
        }
    }
    
    func draw(piece:Piece){
        if let p = piece.position {
            if let pos = piece.position {
                let frame = rectForTileAt(pos.y, pos.x)
                let pieceView = UIView(frame: frame)
                pieceView.layer.cornerRadius = frame.width / 2.0
                pieceView.backgroundColor = piece.player == board.playerA ? UIColor.orangeColor() : UIColor.magentaColor()
                if piece.highlighted {
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
        let w = frame.size.width / CGFloat(board.size)
        let h = frame.size.height / CGFloat(board.size)
        return CGSize(width: w, height: h)
    }
    
    func drawBoard(){
        var columns = board.size
        var rows = board.size
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
        let board = Board(size: 4, a: Player(name: "one"), b: Player(name: "Other"))
        var boardView = BoardView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.width), board: board)
        view.addSubview(boardView)
        boardView.render()
        boardView.onTileTapped = { (pos:Position) in
            let player = board.currentPlayer()
            
            // user selects their own piece == highlight it or unhighlight it
            if let piece = board.pieceAt(pos) {
                if piece.player == player {
                    board.highlight(piece: piece, highlight: !piece.highlighted)
                }
                boardView.render()
                return
            }
            
            // if a piece is highlighted, move a piece
            if let piece = board.highlightedPiece() {
                board.move(piece.position!, to: pos)
                boardView.render()
                return
            }
            
            // if the player has pieces left, play it
            if board.piecesLeftForPlayer(player) > 0 {
                board.play(Piece(player, pos))
                boardView.render()
                return
            }
        }
    }
}