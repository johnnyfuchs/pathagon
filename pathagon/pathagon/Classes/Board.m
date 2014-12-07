//
//  Board.m
//  pathagon
//
//  Created by Johnny Sparks on 12/5/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "Board.h"
#import "OrderedQueue.h"
#import "NSValue+Piece.h"
#import "BoardStructs.h"

static inline int PathHeuristic(Position a, Position b){
    return abs(a.x - b.x) + abs(a.y - b.y);
}

@interface Board ()
@property(nonatomic) uint64_t white;
@property(nonatomic) uint64_t black;
@property(nonatomic) uint64_t whiteRemoved;
@property(nonatomic) uint64_t blackRemoved;
@property(nonatomic) uint64_t highlight;
@end

@implementation Board

- (Player) currentPlayer {
    return (Player) (isPiece(_lastPiece) ? OtherPlayer(_lastPiece.player) : startingPlayer);
}

- (void) add:(Piece)piece {
    uint64_t intPiece = IntPosition(piece.position);
    if (_white & intPiece || _black & intPiece) {
        return;
    }
    if(piece.player == White) {
        _white += intPiece;
    } else {
        _black += intPiece;
    }
    _whiteRemoved = 0;
    _blackRemoved = 0;
    PieceList pieceList = [self piecesTrappedBy:piece];
    [self removePieces:pieceList];
    _lastPiece = piece;
}

- (void) move:(Piece)piece to:(Position)position {
    uint64_t from = IntPosition(piece.position);
    uint64_t to = IntPosition(position);
    if(piece.player == White){
        _white -= from;
        _white += to;
    } else {
        _black -= from;
        _black += to;
    }
}

- (void) remove:(Piece) piece {
    uint64_t intPiece = IntPosition(piece.position);

    if(piece.player == White && _white & intPiece) {
        _white += intPiece;
        _whiteRemoved += intPiece;
    } else if (piece.player == Black && _black & intPiece) {
        _black += intPiece;
        _blackRemoved += intPiece;
    }
}

- (PieceList) removedPieces {
    PieceList all;
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++){
            Position pos = PositionMake(x, y);
            uint64_t intPos = IntPosition(pos);
            if(intPos & _blackRemoved){
                PieceListAddPiece(&all, MakePiece(Black, pos));
            } else if (intPos & _whiteRemoved) {
                PieceListAddPiece(&all, MakePiece(White, pos));
            }
        }
    }
    return all;
}

- (Piece) pieceAt:(Position) pos {
    if (pos.x < 0 || pos.x > boardSize - 1 || pos.y < 0 || pos.y > boardSize - 1) {
        return MakePiece(NotAPlayer, PositionMake(0, 0));
    }
    uint64_t intPiece = IntPosition(pos);
    if (_white & intPiece) {
        return MakePiece(White, pos);
    }
    if (_black & intPiece) {
        return MakePiece(Black, pos);
    }
    return MakePiece(NotAPlayer, PositionMake(0, 0));
}

- (void) highlight:(Position) position {
    if (isPiece([self pieceAt:position])){
        _highlight = IntPosition(position);
    } else {
        _highlight = 0;
    }
}

- (Piece) highlightedPiece {
    enum Player player = NotAPlayer;
    if(_highlight && _black) {
        player = Black;
    } else if (_highlight && _white){
        player = White;
    }
    return MakePiece(player, PositionFromInt(_highlight));
}

- (PieceList) playablePieces {
    Player player = self.currentPlayer;
    PieceList playable;
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++){
            Position pos = PositionMake(x, y);
            uint64_t intPos = IntPosition(pos);
            if(     !( intPos & _black
                    || intPos & _white
                    || intPos & _blackRemoved
                    || intPos & _whiteRemoved)){
                PieceListAddPiece(&playable, MakePiece(player, pos));
            }
        }
    }
    return playable;
}

- (PieceList) allPieces {
    PieceList all;
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++){
            Position pos = PositionMake(x, y);
            uint64_t intPos = IntPosition(pos);
            if(intPos & _black){
                PieceListAddPiece(&all, MakePiece(Black, pos));
            } else if (intPos & _white) {
                PieceListAddPiece(&all, MakePiece(White, pos));
            }
        }
    }
    return all;
}

- (PieceList)connectedPieces:(Piece)piece {
    PieceList all;
    Direction directions[4] = {N, S, E, W};
    for(int i=0; i<4; i++){
        Piece match = [self pieceAt:AddPositions(piece.position, PositionForDirection(directions[i]))];
        if(isPiece(match) && piece.player == match.player){
            PieceListAddPiece(&all, piece);
        }
    }
    return all;
}

- (BOOL) pathExistsFrom:(Piece) start to:(Piece) finish {
    OrderedQueue *frontier = [[OrderedQueue alloc] init];
    [frontier addObject:[NSValue valueWithPiece:start] value:0];
    NSMutableDictionary *costs = [NSMutableDictionary new];

    while (frontier.count){
        Piece currentPiece = ((NSValue *)frontier.pop).pieceValue;
        NSValue *currentPieceValue = [NSValue valueWithPiece:currentPiece];

        if(PiecesEqual(currentPiece, finish)){
            return YES;
        }

        PieceList neighbors = [self connectedPieces:currentPiece];

        for(int idx=0; idx <neighbors.count; idx++){
            Piece neighbor = neighbors.pieces[idx];

            uint newCost = [costs[currentPieceValue] unsignedIntValue] + PathHeuristic(neighbor.position, finish.position);

            NSValue *neighborValue = [NSValue valueWithPiece:neighbor];
            NSNumber *neighborCost = costs[neighborValue];

            if(!neighborCost || newCost < neighborCost.integerValue ){
                costs[neighborValue] = @(newCost);
                uint priority = newCost + PathHeuristic(neighbor.position, finish.position);
                [frontier addObject:neighborValue value:priority];
            }
        }
    }
    return false;
}

-(NSInteger) piecesLeftForPlayer:(Player)player {
    int played = 0;
    PieceList all = [self allPieces];
    for(int i=0; i<all.count; i++){
        Piece piece = all.pieces[i];
        if (piece.player == player){
            played++;
        }
    }
    return piecesPerPlayer - played;
}


- (void)removePieces:(PieceList)list {
    for(int i=0; i< list.count; i++){
        [self remove:list.pieces[i]];
    }
}

- (PieceList)piecesTrappedBy:(Piece)piece {
    PieceList result = PieceListMake();
    Direction directions[4] = {N, S, E, W};
    for(int i=0; i<4; i++) {
        Position directedPosition = AddPositions(piece.position, PositionForDirection(directions[i]));
        Piece captureable = [self pieceAt:directedPosition];
        if(isPiece(captureable) && captureable.player != piece.player){
            Piece trapping = [self pieceAt:AddPositions(directedPosition, PositionForDirection(directions[i]))];
            if(isPiece(trapping) && trapping.player == piece.player){
                PieceListAddPiece(&result, captureable);
            }
        }
    }
    return result;
}

-(BOOL) winExistsForPlayer:(Player)player {
    if([self piecesLeftForPlayer:player] < boardSize){
        return false;
    }

    int lastRow = boardSize - 1;
    PieceList startNodes = player == White ? [self piecesInRow:0 player:player] : [self piecesInCol:0 player:player];
    PieceList endNodes = player == White ? [self piecesInRow:lastRow player:player] : [self piecesInCol:lastRow player:player];

    if( !startNodes.count || !endNodes.count ){
        return NO;
    }
    for(int startIdx=0; startIdx < startNodes.count; startIdx++){
        for(int endIdx=0; endIdx < endNodes.count; endIdx++){
            if ([self pathExistsFrom:startNodes.pieces[startIdx] to:endNodes.pieces[endIdx]]){
                return YES;
            }
        }
    }
    return NO;
}

-(PieceList) piecesInRow:(int)row player:(Player)player {
    PieceList pieces = PieceListMake();
    uint64_t playerInt = player == White ? _white : _black;
    for(int col=0; col < boardSize; col++){
        Position pos = PositionMake(col, row);
        uint64_t pieceInt = IntPosition(pos);
        if(pieceInt &  playerInt){
            PieceListAddPiece(&pieces, MakePiece(player, pos));
        }
    }
    return pieces;
}

-(PieceList) piecesInCol:(int)col player:(Player)player {
    PieceList pieces = PieceListMake();
    uint64_t playerInt = player == White ? _white : _black;
    for(int row=0; row < boardSize; row++){
        Position pos = PositionMake(col, row);
        uint64_t pieceInt = IntPosition(pos);
        if(pieceInt &  playerInt){
            PieceListAddPiece(&pieces, MakePiece(player, pos));
        }
    }
    return pieces;
}

- (NSArray *) childBoards {
    NSMutableArray *boards = [NSMutableArray new];
    PieceList playablePieces = [self playablePieces];
    for(int idx=0; idx < playablePieces.count; idx++){
        Board *child = [self copy];
        [child add:playablePieces.pieces[idx]];
        [boards addObject:child];
    }
    return boards;
}

- (NSString *)description {
    NSString *bar = @"------------------";
    NSMutableString *o = [bar mutableCopy];
    [o appendString:@"\n"];
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++) {
            Position pos = PositionMake(x, y);
            Piece piece = [self pieceAt:pos];
            if(isPiece(piece)){
                [o appendString:piece.player == White ? @"w" : @"b"];
            } else {
                [o appendString:@" "];
            }
        }
        [o appendString:@"\n"];
    }
    [o appendString:bar];
    return o;
}

- (id)copyWithZone:(NSZone *)zone {
    Board *board = [Board new];
    board.white  = _white;
    board.black = _black;
    board.blackRemoved = _blackRemoved;
    board.whiteRemoved = _whiteRemoved;
    board.highlight = _highlight;
    return board;
}


- (BOOL)canPlay:(Piece)piece {
    PieceList playablePieces = [self playablePieces];
    for(int idx=0; idx < playablePieces.count; idx++){
        if(PiecesEqual(piece, playablePieces.pieces[idx])){
            return YES;
        }
    }
    return NO;
}

@end
