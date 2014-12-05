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
    public func otherPlayer() -> Player {
        return self == .White ? .Black : .White
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

public class BoardGrid: Printable, NSCopying {
    var white:UInt64 = 0
    var black:UInt64 = 0
    var whiteRemoved:UInt64 = 0
    var blackRemoved:UInt64 = 0
    var highlight:UInt64 = 0
    let maxSize:UInt64 = 8
    let size:UInt64 = 7
    let one:UInt64 = 1
    public var lastPiece:Piece?
    public let piecesPerPlayer = 14

    public init(){ }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        var board = BoardGrid(size: size)
        board.white = white
        board.black = black
        board.blackRemoved = blackRemoved
        board.whiteRemoved = whiteRemoved
        board.lastPiece = lastPiece
        board.highlight = highlight
        return board
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
        whiteRemoved = 0
        blackRemoved = 0
        let trappedPieces = piecesTrappedBy(piece)
        removePieces(trappedPieces)
        lastPiece = piece
    }
    
    public func remove(piece:Piece) {
        let pos = piece.position
        let intPiece = one << (UInt64(pos.x) * size + UInt64(pos.y))
        if piece.player == .White && (white & intPiece > 0) {
            white -= intPiece
            whiteRemoved += intPiece
        } else if (black & intPiece > 0) {
            black -= intPiece
            blackRemoved += intPiece
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
    
    public func playablePieces() -> [Piece] {
        let player = lastPiece != nil ? lastPiece!.player.otherPlayer() : .White
        let piecesRemoved = removedPieces(player)
        var playable:[Piece] = []
        var found = false
        for piece in emptyPieces(player) {
            found = false
            for removed in piecesRemoved {
                if piece == removed {
                    found = true
                }
            }
            if !found {
                playable.append(piece)
            }
        }
        return playable
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
    
    public func emptyPieces(player:Player) -> [Piece] {
        var pieces:[Piece] = []
        for x in 0...size-1 {
            for y in 0...size-1 {
                let intPiece = one << (x * size + y)
                if black & intPiece == 0 && player == .Black {
                    pieces.append(Piece(.Black, Position(Int(x), Int(y))))
                }
                if white & intPiece == 0 && player == .White {
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
    
    public func pathExists(start:Piece, _ end:Piece) -> Bool {
        
        func heuristic(a:Position, b:Position) -> Int {
            return abs(a.x - b.x) + abs(a.y - b.y)
        }
        
        func neigbors(position:Position) -> [Piece] {
            var pieces:[Piece] = []
            let dirs:[Direction] = [.N, .E, .S, .W]
            for dir in dirs {
                if let piece = pieceAt(position + dir.toCoord()){
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
            
            let neighbors = neigbors(current.position)
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
            remove(piece)
        }
    }
    
    public func removedPieces(player:Player) -> [Piece] {
        var pieces:[Piece] = []
        for x in 0...size-1 {
            for y in 0...size-1 {
                let intPiece = one << (x * size + y)
                if blackRemoved & intPiece > 0 {
                    pieces.append(Piece(.Black, Position(Int(x), Int(y))))
                }
                if whiteRemoved & intPiece > 0 {
                    pieces.append(Piece(.White, Position(Int(x), Int(y))))
                }
            }
        }
        return pieces

    }
    
    public func piecesLeftForPlayer(player:Player) -> Int {
        var playedPieces = 0
        for piece in allPieces() {
            if piece.player == player {
                playedPieces++
            }
        }
        return piecesPerPlayer - playedPieces
    }
    
    public func winExistsFor(player:Player) -> Bool {
        
        if piecesLeftForPlayer(player) < Int(size) {
            return false
        }
        
        var startNodes:[Piece] = player == .White ? piecesInRow(0, player: player) : piecesInCol(0, player: player)
        var endNodes:[Piece] = player == .White ? piecesInRow(size - 1, player: player) : piecesInCol(size - 1, player: player)
        
        if !(startNodes.count > 0 && endNodes.count > 0) {
            return false
        } else {
            for start in startNodes {
                for end in endNodes {
                    if pathExists(start, end) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func piecesInRow(row:Int, player:Player) -> [Piece] {
        var rowPieces:[Piece] = []
        for piece in allPieces() {
            if piece.position.y == row && player == piece.player {
                rowPieces.append(piece)
            }
        }
        return rowPieces
    }
    
    func piecesInCol(col:Int, player:Player) -> [Piece] {
        var colPieces:[Piece] = []
        for piece in allPieces() {
            if piece.position.x == col  && player == piece.player {
                colPieces.append(piece)
            }
        }
        return colPieces
    }
    
    public func childBoards() -> [BoardGrid] {
        var boards:[BoardGrid] = []
        for piece in playablePieces() {
            var board:BoardGrid = copyWithZone(nil) as BoardGrid
            board.add(piece)
            boards.append(board)
        }
        return boards
    }
}

public class Board:Printable {
    
    var size = 7
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
            return lastPlayer.otherPlayer()
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
        for piece in grid.playablePieces() {
            if targetPiece == piece {
                return true
            }
        }
        return false
    }
    
    func toggleHighlight(pos:Position) {
        if pieceAt(pos) != nil {
            grid.highlight(pos)
        } else {
            grid.unhighlight()
        }
    }
    
    func highlightedPiece() -> Piece? {
        return grid.highlighted()
    }
    
    func completeMove(piece:Piece) {
        grid.unhighlight()
        lastPiece = piece
        if winExistsFor(piece.player) {
            self.onWinner(player: piece.player)
        }
    }
    
    public func pieceAt(position:Position) -> Piece? {
        return grid.pieceAt(position)
    }
    
    public func piecesLeftForPlayer(player:Player) -> Int {
        return grid.piecesLeftForPlayer(player)
    }
    
    public func winExistsFor(player:Player) -> Bool {
        return grid.winExistsFor(player)
    }
    
    func allPieces() -> [Piece] {
        return grid.allPieces()
    }
    public var description:String {
        return grid.description
    }
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
        pieceView.backgroundColor = piece.player == .White ? UIColor.greenColor() : UIColor.blueColor()
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
    
    init(_ board:Board) {
        self.board = board
    }
    
    func takeTurn(board:Board) -> Piece {
        let piece = idealPiece()
        if board.canPlay(piece) {
            return piece
        } else {
            return takeTurn(board)
        }
    }
    
    func idealPiece() -> Piece {

        var bestPiece:Piece = Piece(board.currentPlayer(), Position(Int(arc4random_uniform(UInt32(board.size))), Int(arc4random_uniform(UInt32(board.size)))))
        var bestScore = 0
        let childboards = board.grid.childBoards()
        for node in  childboards {
            let alpha = alphabeta(node, 1, Int.min, Int.max, true)
            if alpha > bestScore {
                bestScore = alpha
                bestPiece = node.lastPiece!
            }
        }
        
        return bestPiece
    }
    
    func random() -> Piece {
        let size = UInt32(board.size - 1)
        let pos = Position( Int(arc4random_uniform(size)), Int(arc4random_uniform(size)))
        return Piece(.Black, pos)
    }
}

func hueristic(grid:BoardGrid) -> Int {
    
    if grid.lastPiece == nil {
        return Int(arc4random_uniform(10)) - 10
    }
    
    let piece:Piece = grid.lastPiece!
    let otherPlayer:Player = piece.player == .White ? .Black : .White
    
    if grid.winExistsFor(piece.player) {
        return 999999
    }
    
    // if the piece captures another player
    // thats +100 for each piece
    let removed = grid.removedPieces(otherPlayer).count
    if removed > 0 {
        return 1000 * removed
    }
    
    // if a pieces touches another one of your pieces, that's +10
    // if a piece touches other player, that's -10
    let dirs:[Direction] = [.N, .E, .S, .W]
    var touching = 0
    for d in dirs {
        if let touchingPiece = grid.pieceAt(piece.position + d.toCoord()) {
            if piece.player == otherPlayer {
                touching -= 10
            } else {
                touching += 10
            }
        }
    }
    
    return touching
}

func alphabeta(node:BoardGrid, depth:UInt, startAlpha:Int, startBeta:Int, maximizingPlayer:Bool) -> Int {
    var alpha = startAlpha
    var beta = startBeta
    
    if depth == 0 {
        let huer = hueristic(node)
        if( huer > 10 ){
            println(huer)
        }
        return huer
    }
    if maximizingPlayer {

        for child in node.childBoards() {
            alpha = max(alpha, alphabeta(child, depth - 1, alpha, beta, false))
            println("b \(depth), \(alpha), \(beta), \(maximizingPlayer)")

            if beta <= alpha {
                break;
            }
        }
        return alpha
    } else {
        for child in node.childBoards() {
            beta = min(beta, alphabeta(child, depth - 1, alpha, beta, true))
            println("c \(depth), \(alpha), \(beta), \(maximizingPlayer)")

            if beta <= alpha {
                break;
            }
        }
        return beta
    }
}


class RootViewController: UIViewController {
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let board = Board(size: 7)
        let ai = AIPlayer(board)
        board.onWinner = { (player:Player) in
            let title = "\(player) won"
            UIAlertView(title: "Winner!", message:title, delegate: nil, cancelButtonTitle: "Cancel").show()
        }
        var boardView = BoardView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.width), board: board)
        boardView.center = view.center
        view.addSubview(boardView)
        boardView.render()
        boardView.onTileTapped = { (pos:Position) in
            let player = board.currentPlayer()
            
            // user selects their own piece == highlight it or unhighlight it
            if let piece = board.pieceAt(pos) {
                if piece.player == player {
                    board.toggleHighlight(pos)
                }
                boardView.render()
            }
            
            // if a piece is highlighted, move a piece
            else if let piece = board.highlightedPiece() {
                board.move(piece.position, to: pos)
                boardView.render()
            }
            
            // if the player has pieces left, play it
            else if board.piecesLeftForPlayer(player) > 0 {
                board.play(Piece(player, pos))
                boardView.render()
            }
            
            board.play(ai.takeTurn(board))
            boardView.render()
        }
    }
}