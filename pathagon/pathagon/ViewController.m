//
//  ViewController.m
//  pathagon
//
//  Created by Johnny Sparks on 12/5/14.
//  Copyright (c) 2014 beergrammer. All rights reserved.
//

#import "ViewController.h"
#import "BoardView.h"
#import "Board.h"
#import "AIPlayer.h"

@interface ViewController ()

@property(nonatomic, strong) BoardView *boardView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = self.view.frame.size;
    BoardView *boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width)];
    boardView.center = self.view.center;
    [self.view addSubview:boardView];

    AIPlayer *ai = [AIPlayer new];
    Board *board = [Board new];

    self.boardView = boardView;
    self.boardView.board = board;
    self.boardView.onTap = ^(Position position){
        Player player = [board currentPlayer];
        Piece piece = [board pieceAt:position];
        Piece highlighted = board.highlightedPiece;

        if (isPiece(piece) && piece.player == player) {
            if(PiecesEqual(piece, highlighted)){
                [board unhighlight];
            } else {
                [board highlight:piece.position];
            }
        }

        else if(isPiece(highlighted) && [board canPlay:piece]){
            [board move:board.highlightedPiece to:piece.position];
        }

        else if([board piecesLeftForPlayer:player]){
            [board add:MakePiece(player, position)];
        }

        boardView.board = board;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ai takeTurn:board];
            dispatch_async(dispatch_get_main_queue(), ^{
                boardView.board = board;
            });
        });
    };
}

@end
