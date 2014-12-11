//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "AIPlayer.h"
#import "Board.h"
#import "BoardStructs.h"


NSInteger BoardHeuristicA(Board *board) {
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
        } else if(match.player == OtherPlayer(lastPiece.player)){
            touching -= 5;
        }
    }
    return touching;
}

NSInteger BoardHeuristicB(Board *board){
    NSInteger score = 0;
    if(!isPiece(board.lastPiece)) {
        return 0;
    }

    Player player = board.lastPiece.player;
    if(player == Black){
        // black should maximize filled adjacent rows
        for(int row =0; row < boardSize - 1; row++){
            PieceList a = [board piecesInRow:row player:player];
            PieceList b = [board piecesInRow:row + 1 player:player];
            score = MAX(score, a.count + b.count);
        }
    } else {
        // white should maximize filled adjacent cols
        for(int col =0; col < boardSize - 1; col++){
            PieceList a = [board piecesInCol:col player:player];
            PieceList b = [board piecesInCol:col + 1 player:player];
            score = MAX(score, a.count + b.count);
        }
    }
    return score;
}

NSInteger alphaBeta(Board *board, NSInteger depth, NSInteger alpha, NSInteger beta, BOOL maxing){
    if(!depth){
        return BoardHeuristicB(board);
    }
    
    NSArray *children = board.childBoards;
    if(maxing){
        for(Board *child in children){
            NSInteger newAlpha = alphaBeta(child, depth - 1, alpha, beta, NO);
            alpha = MAX(alpha, newAlpha);
            if(beta <= alpha){
                break;
            }
        }
        return alpha;
    } else {
        for(Board *child in children){
            NSInteger newBeta = alphaBeta(child, depth - 1, alpha, beta, YES);
            beta = MIN(beta, newBeta);
            if(beta <= alpha){
                break;
            }
        }
        return beta;
    }
}


@implementation AIPlayer {
    NSTimeInterval _endThinking;
    NSTimeInterval _startThinking;
}

- (Board *)takeTurn:(Board *)board {
    return [self idealChildBoard:board];
}

- (Board *)idealChildBoard:(Board *)board {
    _startThinking = [NSDate timeIntervalSinceReferenceDate];
    _endThinking = 0;
    NSInteger bestScore = 0;
    Board *bestBoard;
    for(Board *child in board.childBoards){
        if(!bestBoard){
            bestBoard = child;
        }
        NSInteger alpha = alphaBeta(child, 4, -100000000, 100000000, YES);
        if(alpha > bestScore){
            bestScore = alpha;
            board = child;
        }
    }
    _endThinking = [NSDate timeIntervalSinceReferenceDate];
    return board;
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