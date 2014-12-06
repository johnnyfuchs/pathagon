//
// Created by Johnny Sparks on 12/5/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

static const int boardSize = 7;
static const int boardArea = boardSize * 2;

NS_ENUM(NSInteger , Direction){
    N, S, E, W,
};

typedef enum Direction Direction;

NS_ENUM(NSInteger , Player){
    NotAPlayer, White, Black,
};
typedef enum Player Player;

typedef struct {
    int x, y;
} Position;

typedef struct {
    Player player;
    Position position;
} Piece;


typedef struct {
    Piece pieces[boardArea];
    int count;
} PieceList;

static inline Position MakePosition(int x, int y){
    Position pos; pos.x = x; pos.y = y; return pos;
}

static inline Position PositionForDirection(Direction direction) {
    switch (direction){
        case N: return MakePosition(0, -1);
        case S: return MakePosition(0, 1);
        case E: return MakePosition(1, 0);
        case W: return MakePosition(-1, 0);
    }
    return MakePosition(0, 0);
}

static inline Position AddPositions(Position a, Position b) {
    return MakePosition(a.x + b.x, a.y + b.y);
}

static inline uint64_t IntPosition(Position pos) {
    return (uint64_t)1 << (uint64_t)(pos.x * boardSize + pos.y);
}

static inline Position PositionFromInt(uint64_t intPos){
    int base = (int) log2(intPos);
    int y = base % boardSize;
    int x = (base - y) / boardSize;
    return MakePosition(x, y);
}

static inline Player OtherPlayer(Player player) {
    return player == White ? Black : White;
}

static inline BOOL isPiece(Piece piece){
    return piece.player != NotAPlayer;
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

static inline void PieceListAddPiece(PieceList * list, Piece piece){
    assert(list->count < boardArea);
    list->pieces[list->count] = piece;
    list->count++;
}

static inline Piece PieceListLastPiece(PieceList * list){
    return list->pieces[list->count];
}

static inline BOOL isPieceListEmpty(PieceList *list){
    return (BOOL) list->count;
}
