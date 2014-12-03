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

public struct Position:Equatable, Hashable, Printable {
    public let x, y :Int
    public var description:String {
        return "{ x:\(x) y:\(y) }"
    }
    
    public var hashValue:Int {
        return x.hashValue ^ y.hashValue
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

public func !== (lhs: Player, rhs: Player) -> Bool {
    return !(lhs == rhs)
}

public enum Player: Printable, Hashable, Equatable {
    case White, Black
    public var description:String {
        return (self == .White ? "White" : "Black")
    }
}

public func == (lhs: Piece, rhs: Piece) -> Bool {
    return lhs.position == rhs.position && lhs.player == rhs.player;
}

public func !== (lhs:Piece, rhs:Piece) -> Bool {
    return !(lhs == rhs)
}
    
public struct Piece : Printable, Equatable, Hashable {
    public var position:Position
    public var player:Player
    
    public init(_ player:Player, _ position:Position){
        self.player = player
        self.position = position
    }
    
    public var hashValue: Int {
        return player.hashValue ^ position.hashValue
    }
    
    public var description : String {
        return "\nplayer: {\(player)}, position: \(position)"
    }
}

public class BoardGrid: Printable {
    var white:UInt64 = 0
    var black:UInt64 = 0
    var highlight:UInt64 = 0
    let maxSize:UInt64 = 8
    let size:UInt64 = 7
    let one:UInt64 = 1

    public init(){
    }
    
    public init(size:UInt64) {
        assert(size <= maxSize, "Cannot have a board larger than 8x8")
        self.size = size
    }
    
    public func add(piece:Piece){
        let pos = piece.position
        let intPiece = one << (UInt64(pos.x) * size + UInt64(pos.y))
        if (white & intPiece > 0) || (black & intPiece > 0) {
            return
        }
        if piece.player == .White {
            white += intPiece
        } else {
            black += intPiece
        }
    }
    
    public func remove(piece:Piece) {
        let pos = piece.position
        let intPiece = one << (UInt64(pos.x) * size + UInt64(pos.y))
        if piece.player == .White && (white & intPiece > 0) {
            white -= intPiece
        } else if (black & intPiece > 0) {
            black -= intPiece
        }
    }
    
    public func pieceAt(pos:Position) -> Piece? {
        if pos.x < 0 || pos.x > Int(size) - 1 || pos.y < 0 || pos.y > Int(size) - 1 {
            return nil
        }
        let intPiece = one << (UInt64(pos.x) * size + UInt64(pos.y))
        if white & intPiece > 0 {
            return Piece(.White, pos)
        }
        if black & intPiece > 0 {
            return Piece(.Black, pos)
        }
        return nil
    }
    
    public func highlight(pos:Position) {
        if pieceAt(pos) != nil {
            let intPiece = one << (UInt64(abs(pos.x)) * size + UInt64(abs(pos.y)))
            highlight = intPiece
        }
    }
    
    public func unhighlight() {
        highlight = 0
    }
    
    public func highlighted() -> Piece? {
        for x in 0...size-1 {
            for y in 0...size-1 {
                let intPiece = one << (x * size + y)
                if highlight & intPiece > 0 {
                    return pieceAt(Position(Int(x), Int(y)))
                }
            }
        }
        return nil
    }
    
    public func allPieces() -> [Piece] {
        var pieces:[Piece] = []
        for x in 0...size-1 {
            for y in 0...size-1 {
                let intPiece = one << (x * size + y)
                if black & intPiece > 0 {
                    pieces.append(Piece(.Black, Position(Int(x), Int(y))))
                }
                if white & intPiece > 0 {
                    pieces.append(Piece(.White, Position(Int(x), Int(y))))
                }
            }
        }
        return pieces
    }
    
    public var description:String {
        var o = "---------------\n"
        for y:Int in 0...size-1 {
            o += "|"
            for x:Int in 0...size-1 {
                if let piece = pieceAt(Position(x, y)) {
                    o += piece.player == .White ? "w" : "b"
                } else {
                    o += " "
                }
            }
            o += "|\n"
        }
        o += "---------------"
        return o
    }
}

public class Board:Printable {
    
    var size = 7
    public let piecesPerPlayer = 14
    var removedPieces:[Piece] = []
    let goals:[Direction] = [.N, .S, .E, .W]
    var lastPiece:Piece?
    var grid:BoardGrid
    
    var onWinner:(player:Player) -> () = { (player) in }
    
    public init(size:Int) {
        self.size = size
        grid = BoardGrid(size: UInt64(size))
    }
    
    public func currentPlayer() -> Player {
        if let lastPlayer = lastPiece?.player {
            if lastPlayer == .White {
                return .Black
            }
        }
        return .White
    }
    
    public func move(from:Position, to:Position) -> Bool {
        if let piece = pieceAt(from) {
            let destination = Piece(piece.player, to)
            if canPlay(destination) {
                completeMove(destination)
                return true
            }
        }
        return false
    }
    
    public func play(piece:Piece) -> Bool {
        if canPlay(piece) {
            grid.add(piece)
            completeMove(piece)
            return true
        }
        return true
    }
    
    public func canPlay(targetPiece:Piece) -> Bool {
        let pos = targetPiece.position
        
        if pieceAt(pos) != nil {
            return false
        }
        
        for piece in removedPieces {
            if piece.position == pos {
                return false
            }
        }
        
        return true
    }
    
    func highlight(piece pieceToHighlight:Piece, highlight:Bool){
        if !highlight {
            grid.unhighlight()
        } else {
            if pieceAt(pieceToHighlight.position) != nil {
                grid.highlight(pieceToHighlight.position)
            }
        }
    }
    
    func highlightedPiece() -> Piece? {
        return grid.highlighted()
    }
    
    func completeMove(piece:Piece) {
        grid.unhighlight()
        lastPiece = piece
        let trappedPieces = piecesTrappedBy(piece)
        removePieces(trappedPieces)
        removedPieces = trappedPieces
        if winExistsFor(piece.player) {
            self.onWinner(player: piece.player)
        }
    }
    
    public func pieceAt(position:Position) -> Piece? {
        return grid.pieceAt(position)
    }
    
    public func piecesTrappedBy(piece:Piece) -> [Piece] {
        let player = piece.player
        var matches:[Piece] = []
        let dirs:[Direction] = [.N, .S, .E, .W]
        let pos = piece.position
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
        return matches
    }
    
    public func removePieces(piecesToRemove:[Piece]) {
        for piece in piecesToRemove {
            grid.remove(piece)
        }
    }
    
    public func piecesLeftForPlayer(player:Player) -> Int {
        var playedPieces = 0
        for piece in grid.allPieces() {
            if piece.player == player {
                playedPieces++
            }
        }
        return piecesPerPlayer - playedPieces
    }
    
    public func winExistsFor(player:Player) -> Bool {
        
        var startNodes:[Piece] = player == .White ? piecesInRow(0, player: player) : piecesInCol(0, player: player)
        var endNodes:[Piece] = player == .White ? piecesInRow(size - 1, player: player) : piecesInCol(size - 1, player: player)
        
        if !(startNodes.count > 0 && endNodes.count > 0) {
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
    
    func piecesInRow(row:Int, player:Player) -> [Piece] {
        var rowPieces:[Piece] = []
        for piece in grid.allPieces() {
            if piece.position.y == row && player == piece.player {
                rowPieces.append(piece)
            }
        }
        return rowPieces
    }
    
    func piecesInCol(col:Int, player:Player) -> [Piece] {
        var colPieces:[Piece] = []
        for piece in grid.allPieces() {
            if piece.position.x == col  && player == piece.player {
                colPieces.append(piece)
            }
        }
        return colPieces
    }
    
    func allPieces() -> [Piece] {
        return grid.allPieces()
    }
    public var description:String {
        return grid.description
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
                if piece.player == start.player {
                    pieces.append(piece)
                }
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
        
        let neighbors = neigbors(board, current.position)
        for neighbor in neighbors {
            let newCost = costs[current] ?? 0 + heuristic(neighbor.position, end.position)
            
            if costs[neighbor] == nil || newCost < (costs[neighbor] ?? 0) {
                costs[neighbor] = newCost
                let priority = newCost + heuristic(neighbor.position, end.position)
                frontier.push(priority, item: neighbor)
                path[neighbor] = current
            }
        }
    }
    
    return false
}

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
        for p in board.allPieces() {
            draw(p)
        }
    }
    
    func draw(piece:Piece){
        let pos = piece.position
        let frame = rectForTileAt(pos.y, pos.x)
        let pieceView = UIView(frame: frame)
        pieceView.layer.cornerRadius = frame.width / 2.0
        pieceView.backgroundColor = piece.player == .White ? UIColor.whiteColor() : UIColor.blackColor()
        if let highlightedPiece = board.highlightedPiece() {
            if highlightedPiece == piece {
                pieceView.backgroundColor = UIColor.yellowColor()
            }
        }
        self.addSubview(pieceView)
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


class AIPlayer {
    
    var board:Board
    
    init( board:Board) {
        self.board = board
    }
    
    func play(board:Board) -> Piece {
        return random()
    }
    
    func random() -> Piece {
        let pos = Position(board.size - 2, board.size - 1)
        return Piece(.Black, pos)
    }
}

class RootViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let board = Board(size: 7)
        board.onWinner = { (player:Player) in
            let title = "\(player) won"
            UIAlertView(title: "Winner!", message:title, delegate: nil, cancelButtonTitle: "Cancel").show()
        }
        var boardView = BoardView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.width), board: board)
        view.addSubview(boardView)
        boardView.render()
        boardView.onTileTapped = { (pos:Position) in
            let player = board.currentPlayer()
            
            // user selects their own piece == highlight it or unhighlight it
            if let piece = board.pieceAt(pos) {
                if piece.player == player {
                    var highlight = false
                    if let highlightedPiece = board.highlightedPiece() {
                        highlight = piece == highlightedPiece
                    }
                    board.highlight(piece: piece, highlight: highlight)
                }
                boardView.render()
                return
            }
            
            // if a piece is highlighted, move a piece
            if let piece = board.highlightedPiece() {
                board.move(piece.position, to: pos)
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