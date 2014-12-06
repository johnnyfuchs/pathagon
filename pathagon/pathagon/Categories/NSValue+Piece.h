//
// Created by Johnny Sparks on 12/5/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardStructs.h"

@interface NSValue (Piece)
+ (id)valueWithPiece:(Piece)piece;
- (Piece)pieceValue;
@end
