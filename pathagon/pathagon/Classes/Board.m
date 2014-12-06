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

@implementation Board
{
    uint64_t _white;
    uint64_t _black;
    uint64_t _whiteRemoved;
    uint64_t _blackRemoved;
    uint64_t _highlight;
    uint64_t _maxSize;
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
    _lastPiece = PieceListLastPiece(&pieceList);
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

- (Piece) pieceAt:(Position) pos {
    if (pos.x < 0 || pos.x > boardSize - 1 || pos.y < 0 || pos.y > boardSize - 1) {
        return MakePiece(NotAPlayer, MakePosition(0, 0));
    }
    uint64_t intPiece = IntPosition(pos);
    if (_white & intPiece) {
        return MakePiece(White, pos);
    }
    if (_black & intPiece) {
        return MakePiece(Black, pos);
    }
    return MakePiece(NotAPlayer, MakePosition(0, 0));
}

- (void) highlight:(Position) position {
    if (isPiece([self pieceAt:position])){
        _highlight = IntPosition(position);
    }
}

- (void) removeHighlight {
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
    Player player = isPiece(_lastPiece) ? OtherPlayer(_lastPiece.player) : startingPlayer;
    PieceList playable;
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++){
            Position pos = MakePosition(x, y);
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
            Position pos = MakePosition(x, y);
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
    NSMutableDictionary *path = [NSMutableDictionary new];
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


- (void)removePieces:(PieceList)list {
    
}

- (PieceList)piecesTrappedBy:(Piece)piece {
    PieceList result;
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

- (NSString *)description {
    NSString *bar = @"------------------";
    NSMutableString *o = [bar mutableCopy];
    [o appendString:@"\n"];
    for (int x=0; x<boardSize-1; x++){
        for(int y=0; y<boardSize-1; y++) {
            Position pos = MakePosition(x, y);
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

@end
