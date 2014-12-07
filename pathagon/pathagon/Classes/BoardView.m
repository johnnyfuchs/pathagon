//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "BoardView.h"
#import "Board.h"
#import "BoardStructs.h"

static inline BOOL altTile(int x, int y){
    return (y % 2 && !(x % 2)) || (!(y % 2) && x % 2);
}

@implementation BoardView {
    CGFloat _tileSize;
    UIColor *white;
    UIColor *gray;
    UIColor *yellow;
    UIColor *green;
    UIColor *blue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        white = [UIColor whiteColor];
        gray = [UIColor lightGrayColor];
        yellow = [UIColor yellowColor];
        green = [UIColor greenColor];
        blue = [UIColor blueColor];
        _tileSize = self.frame.size.width / boardSize;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }

    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    CGSize size = self.frame.size;
    int col = (int) floor((point.x / size.width) * boardSize);
    int row = (int) floor((point.y / size.height) * boardSize);
    self.onTap(PositionMake(col, row));
}

- (void)setBoard:(Board *)board {
    _board = board;
    [self refresh];
}

- (void) refresh {

    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }

    Piece highlighted = [_board highlightedPiece];
    for(int x=0; x < boardSize; x++){
        for(int y=0; y < boardSize; y++){
            Position pos = PositionMake(x, y);
            UIColor *tileColor = altTile(x, y)? white : gray;
            UIView *tile = [self tileWithPosition:pos color:tileColor];
            [self addSubview:tile];
            Piece piece = [_board pieceAt:pos];
            if(isPiece(piece)){
                UIColor *color = piece.player == White ? blue : green;
                if(PiecesEqual(highlighted, piece)){
                    color = yellow;
                }
                UIView *pieceView = [self pieceWithPosition:pos color:color];
                [self addSubview:pieceView];
            }
        }
    }
}

- (UIView *) pieceWithPosition:(Position)pos color:(UIColor *)color {
    UIView *piece = [self tileWithPosition:pos color:color];
    piece.layer.cornerRadius = _tileSize / 2;
    return piece;
}

- (UIView *) tileWithPosition:(Position)pos color:(UIColor *)color {
    UIView *view = [UIView new];
    view.frame = CGRectMake(pos.x * _tileSize, pos.y * _tileSize, _tileSize, _tileSize);
    view.backgroundColor = color;
    return view;
}

@end