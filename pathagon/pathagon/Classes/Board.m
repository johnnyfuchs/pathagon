//
//  Board.m
//  pathagon
//
//  Created by Johnny Sparks on 12/5/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "Board.h"
#import "PriorityQueue.h"
#import "NSValue+Piece.h"
#import "BoardStructs.h"
#import "AIPlayer.h"

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
    uint64_t intPiece = IntFromPosition(piece.position);
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
    uint64_t from = IntFromPosition(piece.position);
    uint64_t to = IntFromPosition(position);
    if(piece.player == White){
        _white -= from;
        _white += to;
    } else {
        _black -= from;
        _black += to;
    }
}

- (void) remove:(Piece) piece {
    uint64_t intPiece = IntFromPosition(piece.position);

    if(piece.player == White && _white & intPiece) {
        _white -= intPiece;
        _whiteRemoved += intPiece;
    } else if (piece.player == Black && _black & intPiece) {
        _black -= intPiece;
        _blackRemoved += intPiece;
    }
}

- (PieceList) removedPieces {
    PieceList all = PieceListMake();
    for (int x=0; x<boardSize; x++){
        for(int y=0; y<boardSize; y++){
            Position pos = PositionMake(x, y);
            uint64_t intPos = IntFromPosition(pos);
            if(intPos & _blackRemoved){
                PieceListAppend(&all, MakePiece(Black, pos));
            } else if (intPos & _whiteRemoved) {
                PieceListAppend(&all, MakePiece(White, pos));
            }
        }
    }
    return all;
}

- (Piece) pieceAt:(Position) pos {
    if (pos.x < 0 || pos.x >= boardSize || pos.y < 0 || pos.y >= boardSize) {
        return MakePiece(NotAPlayer, PositionMake(0, 0));
    }
    uint64_t intPiece = IntFromPosition(pos);
    if (_white & intPiece) {
        return MakePiece(White, pos);
    }
    if (_black & intPiece) {
        return MakePiece(Black, pos);
    }
    return MakePiece(NotAPlayer, PositionMake(0, 0));
}

- (void) highlight:(Position) position {
    if (isPiece([self pieceAt:position])) {
        _highlight = IntFromPosition(position);
    }
}

- (void) unhighlight {
    _highlight = 0;
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
    PieceList list = PieceListMake();
    uint64_t ip;
    Position pos;
    BOOL open;

    for (int x=0; x<boardSize; x++){
        for(int y=0; y<boardSize; y++){
            pos = PositionMake(x, y);
            ip = IntFromPosition(pos);
            open = !(_white & ip) && !(_black & ip) && !(_whiteRemoved & ip) && !(_blackRemoved & ip);
            if(open) {
                Piece piece = MakePiece(player, pos);
                PieceListAppend(&list, piece);
            }
        }
    }
    return list;
}

- (PieceList) allPieces {
    PieceList all = PieceListMake();
    for (int x=0; x<boardSize; x++){
        for(int y=0; y<boardSize; y++){
            Position pos = PositionMake(x, y);
            uint64_t intPos = IntFromPosition(pos);
            if(intPos & _black){
                PieceListAppend(&all, MakePiece(Black, pos));
            } else if (intPos & _white) {
                PieceListAppend(&all, MakePiece(White, pos));
            }
        }
    }
    return all;
}

- (PieceList)connectedPieces:(Piece)piece {
    PieceList all = PieceListMake();
    Direction directions[4] = {N, S, E, W};
    for(int i=0; i<4; i++){
        Piece match = [self pieceAt:AddPositions(piece.position, PositionForDirection(directions[i]))];
        if(isPiece(match) && piece.player == match.player){
            PieceListAppend(&all, match);
        }
    }
    return all;
}

- (BOOL) pathExistsFrom:(Piece) start to:(Piece) finish {
    PriorityQueue *frontier = [[PriorityQueue alloc] init];
    [frontier add:[NSValue valueWithPiece:start] priority:0];
    NSMutableDictionary *costs = [NSMutableDictionary new];
    NSMutableDictionary *path = [NSMutableDictionary new];

    while (frontier.count){
        
        Piece currentPiece = ((NSValue *)frontier.pop).pieceValue;
        NSValue *currentPieceValue = [NSValue valueWithPiece:currentPiece];
        if(PiecesEqual(currentPiece, finish)){
            return YES;
        }

        PieceList neighbors = [self connectedPieces:currentPiece];
        while (!PieceListIsEmpty(&neighbors)) {
            
            Piece neighbor = PieceListNextPiece(&neighbors);
            uint newCost = [costs[currentPieceValue] unsignedIntValue] + PathHeuristic(neighbor.position, finish.position);
            NSValue *neighborValue = [NSValue valueWithPiece:neighbor];
            NSNumber *neighborCost = costs[neighborValue];
            
            if(!neighborCost || newCost < neighborCost.integerValue ){
                
                uint priority = newCost + PathHeuristic(neighbor.position, finish.position);
                costs[neighborValue] = @(newCost);
                path[neighborValue] = currentPieceValue;
                [frontier add:neighborValue priority:priority];
            }
        }
    }
    return NO;
}

-(NSInteger) piecesLeftForPlayer:(Player)player {
    NSInteger played = 0;
    PieceList all = [self allPieces];
    while (!PieceListIsEmpty(&all)) {
        Piece piece = PieceListNextPiece(&all);
        if (piece.player == player){
            played++;
        }
    }
    return piecesPerPlayer - played;
}


- (void)removePieces:(PieceList)list {
    while(!PieceListIsEmpty(&list)){
        [self remove:PieceListNextPiece(&list)];
    }
}

- (PieceList)piecesTrappedBy:(Piece)piece {
    PieceList list = PieceListMake();
    Direction directions[4] = {N, S, E, W};
    for(int i=0; i<4; i++) {
        Position directedPosition = AddPositions(piece.position, PositionForDirection(directions[i]));
        Piece captureable = [self pieceAt:directedPosition];
        if(isPiece(captureable) && captureable.player != piece.player){
            Piece trapping = [self pieceAt:AddPositions(directedPosition, PositionForDirection(directions[i]))];
            if(isPiece(trapping) && trapping.player == piece.player){
                PieceListAppend(&list, captureable);
            }
        }
    }
    return list;
}

-(BOOL) winExistsForPlayer:(Player)player {

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
        uint64_t pieceInt = IntFromPosition(pos);
        if(pieceInt &  playerInt){
            PieceListAppend(&pieces, MakePiece(player, pos));
        }
    }
    return pieces;
}

-(PieceList) piecesInCol:(int)col player:(Player)player {
    PieceList pieces = PieceListMake();
    uint64_t playerInt = player == White ? _white : _black;
    for(int row=0; row < boardSize; row++){
        Position pos = PositionMake(col, row);
        uint64_t pieceInt = IntFromPosition(pos);
        if(pieceInt &  playerInt){
            PieceListAppend(&pieces, MakePiece(player, pos));
        }
    }
    return pieces;
}

- (NSArray *) childBoards {
    NSMutableArray *boards = [NSMutableArray new];
    PieceList playablePieces = [self playablePieces];
    while(!PieceListIsEmpty(&playablePieces)){
        Board *child = [self copy];
        [child add:PieceListNextPiece(&playablePieces)];
        [boards addObject:child];
    }
    return boards;
}

- (NSString *)description {

    NSMutableString *o = [NSMutableString new];
    NSString *bar = @"-------";
    [o appendString:@"\n"];
    [o appendString:bar];
    [o appendString:@"\n"];
    for (int y=0; y<boardSize; y++){
        [o appendString:@"|"];
        for(int x=0; x<boardSize; x++) {
            Position pos = PositionMake(x, y);
            Piece piece = [self pieceAt:pos];
            if(isPiece(piece)){
                [o appendString:piece.player == White ? @"w" : @"b"];
            } else {
                [o appendString:@" "];
            }
        }
        [o appendString:@"|\n"];
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
    uint64_t ip;
    BOOL open;
    ip = IntFromPosition(piece.position);
    open = !(_white & ip) && !(_black & ip) && !(_whiteRemoved & ip) && !(_blackRemoved & ip);
    return open;
}

@end
