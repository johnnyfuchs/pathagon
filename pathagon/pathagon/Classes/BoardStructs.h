//
// Created by Johnny Sparks on 12/5/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int boardSize = 7;
static const int boardArea = boardSize * boardSize;

enum Direction {
    N, S, E, W,
    NE, SE,
    NW, SW,
};
typedef enum Direction Direction;

enum Player {
    NotAPlayer, White, Black,
};
typedef enum Player Player;

struct Position {
    int8_t x, y;
};
typedef struct Position Position;

struct Piece {
    Player player;
    Position position;
};
typedef struct Piece Piece;


static inline Position PositionMake(int x, int y){
    Position pos; pos.x = x; pos.y = y; return pos;
}

static inline Position PositionForDirection(Direction direction) {
    switch (direction){
        case N: return PositionMake(0, -1);
        case S: return PositionMake(0, 1);
        case E: return PositionMake(1, 0);
        case W: return PositionMake(-1, 0);
        case NE: return PositionMake(1, -1);
        case NW: return PositionMake(-1, -1);
        case SE: return PositionMake(1, 1);
        case SW: return PositionMake(-1, 1);
    }
    return PositionMake(0, 0);
}

static inline Position AddPositions(Position a, Position b) {
    return PositionMake(a.x + b.x, a.y + b.y);
}

static inline uint64_t IntFromPosition(Position pos) {
    return (uint64_t)1 << (uint64_t)(pos.x * boardSize + pos.y);
}

static inline Position PositionFromInt(uint64_t intPos){
    int base = (int) log2(intPos);
    int y = base % boardSize;
    int x = (base - y) / boardSize;
    return PositionMake(x, y);
}

static inline Player OtherPlayer(Player player) {
    return player == White ? Black : White;
}

static inline BOOL isPiece(Piece piece){
    return piece.player != NotAPlayer;
}

static inline NSString *NSStringFromPiece(Piece piece) {
    NSString *player = piece.player == NotAPlayer ? @"NotAPlayer" : piece.player == White ? @"White" : @"Black";
    return [NSString stringWithFormat:@"piece p: %@ (x: %i, y:%i)", player, piece.position.x, piece.position.y];
}

static inline Piece MakePiece(Player player, Position position){
    Piece piece; piece.player = player; piece.position = position; return piece;
}

static inline BOOL PositionsEqual(Position a, Position b){
    return a.x == b.x && a.y == b.y;
}

static inline BOOL PiecesEqual(Piece a, Piece b){
    return a.player == b.player && PositionsEqual(a.position, b.position);
}

/**
* Piece List
*/
struct PieceList {
    Piece pieces[boardArea];
    uint count;
    uint next;
};
typedef struct PieceList PieceList;

static inline PieceList PieceListMake() {
    PieceList list;
    list.count = 0;
    list.next = 0;
    memset(list.pieces, 0, sizeof(list.pieces));
    return list;
}

static inline void PieceListAppend(PieceList *list, Piece piece){
    list->pieces[list->count] = piece;
    list->count += 1;
}

static inline Piece PieceListNextPiece(PieceList * list){
    assert(list->count);
    Piece piece = list->pieces[list->next];
    list->next += 1;
    list->count -= 1;
    return piece;
}

static inline BOOL PieceListIsEmpty(PieceList *list){
    return (BOOL) list->count == 0;
}
