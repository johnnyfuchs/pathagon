//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "AIPlayer.h"
#import "Board.h"
#import "BoardStructs.h"


NSInteger heuristic(Board *board) {
    if(!isPiece(board.lastPiece)) {
        return arc4random_uniform(10);
    }

    Piece lastPiece = board.lastPiece;

    if([board winExistsForPlayer:lastPiece.player]){
        return 99999;
    }

    PieceList removed = [board removedPieces];
    if(removed.count){
        return removed.count * 10;
    }

    Direction directions[4] = {N, S, E, W};
    int touching = 0;
    for(int i=0; i<4; i++){
        Piece match = [board pieceAt:AddPositions(lastPiece.position, PositionForDirection(directions[i]))];
        if(match.player == lastPiece.player){
            touching += 10;
        }
    }
    return touching;
}

NSInteger alphabeta(Board *board, NSInteger depth, NSInteger alpha, NSInteger beta, BOOL maxing){
    if(!depth){
        return heuristic(board);
    }

    if(maxing){
        NSArray *children = board.childBoards;
        for(Board *child in children){
            alpha = MAX(alpha, alphabeta(child, depth - 1, alpha, beta, NO));
            if(beta <= alpha){
                break;
            }
        }
        return alpha;
    } else {
        NSArray *children = board.childBoards;
        for(Board *child in children){
            beta = MIN(beta, alphabeta(child, depth - 1, alpha, beta, NO));
            if(beta <= alpha){
                break;
            }
        }
        return beta;
    }
}


@implementation AIPlayer

- (void)takeTurn:(Board *)board {
    Piece piece = [self idealPiece:board];
    [board add:piece];
}

- (Piece) idealPiece:(Board *)board {
    NSInteger bestScore = 0;
    Piece piece = MakePiece(board.currentPlayer, PositionMake(arc4random_uniform(boardSize), arc4random_uniform(boardSize)));
    for(Board *child in board.childBoards){
        NSInteger alpha = alphabeta(child, 4, NSIntegerMin, NSIntegerMax, YES);
        if(alpha > bestScore){
            bestScore = alpha;
            piece = board.lastPiece;
        }
    }
    return piece;
}

- (Piece) randomPiece:(Board *)board {
    NSArray *children = board.childBoards;
    return ((Board *)children[(NSUInteger)arc4random_uniform((uint)children.count)]).lastPiece;
}

@end