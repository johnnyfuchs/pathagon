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
@property(nonatomic, strong) UILabel *timerLabel;
@property(nonatomic, strong) BoardView *boardView;
@property(nonatomic, strong) AIPlayer *ai;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGSize size = self.view.frame.size;
    BoardView *boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width)];
    boardView.center = self.view.center;
    [self.view addSubview:boardView];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 50)];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timerLabel];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];

    self.ai = [AIPlayer new];
    Board *board = [Board new];

    self.boardView = boardView;
    self.boardView.board = board;
    __weak typeof(self) wself = self;
    self.boardView.onTap = ^(Position position){

        wself.boardView.userInteractionEnabled = NO;

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

        if(isPiece(highlighted) && [board canPlay:piece]){
            [board move:board.highlightedPiece to:piece.position];
        }

        else if([board piecesLeftForPlayer:player]){
            [board add:MakePiece(player, position)];
        }
        
        if([board winExistsForPlayer:player]){
            [[[UIAlertView alloc] initWithTitle:@"Win" message:(player == White ? @"White" : @"Black") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }

        boardView.board = board;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Board *aiBoard = [wself.ai takeTurn:board];
            dispatch_async(dispatch_get_main_queue(), ^{
                boardView.board = aiBoard;
                wself.boardView.userInteractionEnabled = YES;
            });
        });
    };
}

- (void) updateTimerLabel {
    self.timerLabel.text = [NSString stringWithFormat:@"%.2f", self.ai.thinkingTime];
}

@end
