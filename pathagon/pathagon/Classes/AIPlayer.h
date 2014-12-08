//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Board;

NSInteger heuristic(Board *board);
NSInteger alphabeta(Board *board, NSInteger depth, NSInteger alpha, NSInteger beta, BOOL maxing);

@interface AIPlayer : NSObject

- (void) takeTurn:(Board *)board;

@end