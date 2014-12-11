//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Board;

NSInteger BoardHeuristicA(Board *board);
NSInteger alphabeta(Board *board, NSInteger depth, BOOL maxing);

@interface AIPlayer : NSObject

@property(nonatomic, readonly) NSTimeInterval thinkingTime;

- (Board *) takeTurn:(Board *)board;

@end