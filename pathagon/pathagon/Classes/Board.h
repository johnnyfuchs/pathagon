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

@interface Board : NSObject <NSCopying>
@property (nonatomic, readonly) Piece lastPiece;

- (Player)currentPlayer;

- (void)add:(Piece)piece;

- (void)move:(Piece)piece to:(Position)position;

- (PieceList)removedPieces;

- (Piece)pieceAt:(Position)pos;

- (void)highlight:(Position)position;

- (void)unhighlight;

- (Piece)highlightedPiece;

- (NSInteger)piecesLeftForPlayer:(Player)player;

- (BOOL)winExistsForPlayer:(Player)player;

- (NSArray *)childBoards;

- (BOOL)canPlay:(Piece)piece;

- (PieceList)piecesTrappedBy:(Piece)piece;

@end
