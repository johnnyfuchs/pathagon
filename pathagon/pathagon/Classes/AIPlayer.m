//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "AIPlayer.h"
#import "Board.h"
#import "BoardStructs.h"


NSInteger BoardHeuristic(Board *board) {
    if(!isPiece(board.lastPiece)) {
        return 0;
    }

    Piece lastPiece = board.lastPiece;

    if([board winExistsForPlayer:lastPiece.player]){
        return 99999;
    }

    PieceList removed = [board removedPieces];
    if(removed.count){
        return removed.count * 100;
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

NSInteger alphabeta(Board *board, NSInteger depth, BOOL maxing){
    NSInteger alpha = -100000000;
    NSInteger beta = 100000000;
    if(!depth){
        return BoardHeuristic(board);
    }
    
    NSArray *children = board.childBoards;
    if(maxing){
        for(Board *child in children){
            NSInteger newAlpha = alphabeta(child, depth - 1, NO);
            alpha = MAX(alpha, newAlpha);
        }
        return alpha;
    } else {
        for(Board *child in children){
            NSInteger newBeta = alphabeta(child, depth - 1, YES);
            beta = MIN(beta, newBeta);
        }
        return beta;
    }
}


@implementation AIPlayer {
    NSTimeInterval _endThinking;
    NSTimeInterval _startThinking;
}

- (void)takeTurn:(Board *)board {
    Piece piece = [self idealPiece:board];
    if([board canPlay:piece]){
        [board add:piece];
    }
}

- (Piece) idealPiece:(Board *)board {
    _startThinking = [NSDate timeIntervalSinceReferenceDate];
    _endThinking = 0;
    NSInteger bestScore = 0;
    Piece piece = MakePiece(board.currentPlayer, PositionMake(arc4random_uniform(boardSize), arc4random_uniform(boardSize)));
    for(Board *child in board.childBoards){
        NSInteger alpha = BoardHeuristic(child);
        NSLog(@"%li, %@", (long)alpha, child);
        if(alpha > bestScore){
            bestScore = alpha;
            piece = child.lastPiece;
        }
    }
    _endThinking = [NSDate timeIntervalSinceReferenceDate];
    return piece;
}

- (Piece) randomPiece:(Board *)board {
    NSArray *children = board.childBoards;
    return ((Board *)children[(NSUInteger)arc4random_uniform((uint)children.count)]).lastPiece;
}

- (NSTimeInterval) thinkingTime {
    if (!_startThinking) {
        return 0;
    }
    if(!_endThinking){
        return [NSDate timeIntervalSinceReferenceDate] - _startThinking;
    }
    return _endThinking - _startThinking;
}

@end