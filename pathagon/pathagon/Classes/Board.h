//
//  Board.h
//  pathagon
//
//  Created by Johnny Sparks on 12/5/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardStructs.h"

static const int piecesPerPlayer = 7;

static const Player startingPlayer = White;

@interface Board : NSObject
@property (nonatomic, readonly) Piece lastPiece;
@end
