//
// Created by Johnny Sparks on 12/6/14.
// Copyright (c) 2014 beergrammer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BoardStructs.h"

@class Board;

@interface BoardView : UIView
@property (nonatomic, strong) Board *board;
@property (nonatomic, copy) void (^onTap)(Board *, Position position);
@end