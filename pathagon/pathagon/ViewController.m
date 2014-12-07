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
        if(isPiece(piece)){
            [board highlight:piece.position];
        }

        else if(isPiece(board.highlightedPiece)){
            [board move:board.highlightedPiece to:piece.position];
        }

        else if([board piecesLeftForPlayer:player]){
            [board add:MakePiece(player, position)];
        }

        boardView.board = board;
        //[ai takeTurn:board];
        boardView.board = board;
    };
}

@end
