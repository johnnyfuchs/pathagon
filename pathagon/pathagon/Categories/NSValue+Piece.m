//
// Created by Johnny Sparks on 12/5/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "NSValue+Piece.h"

@implementation NSValue (Piece)

+ (id)valueWithPiece:(Piece)piece
{
    return [NSValue value:&piece withObjCType:@encode(Piece)];
}
- (Piece)pieceValue
{
    Piece piece; [self getValue:&piece]; return piece;
}
@end