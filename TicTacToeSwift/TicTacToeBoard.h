//
//  TicTacToeEngine.h
//  TicTacToe
//
//  Created by id on 3/19/16.
//  Copyright © 2016 Brandon Gress. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, GameState) {
    GameStateEmpty = 1 << 0,
    GameStateStarted = 1 << 1,
    GameStateWon = 1 << 2,
    GameStateTied = 1 << 3,
    GameStateOver = GameStateTied | GameStateWon
};

@interface TicTacToeBoard : NSObject

@property NSString *playerTurn;
@property NSUInteger boardSize;
@property NSMutableString *boardState;       // 0 for "O", 1 for "X", " " if not yet played
@property GameState currentGameState;

-(void) restartGame;
-(void) updateBoardForCurrentPlayerAtRow:(NSUInteger) row atColumn:(NSUInteger)column; // 1 indexed for human brains
-(BOOL) canUpdateBoardAtRow:(NSUInteger) row atColumn:(NSUInteger) column;
-(instancetype) initWithBoardSize:(NSUInteger)boardSize boardState:(NSString *)board;
-(instancetype) initWithBoardSize:(NSUInteger)boardSize;

@end
