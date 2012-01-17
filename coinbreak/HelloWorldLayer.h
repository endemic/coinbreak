//
//  HelloWorldLayer.h
//  bit-break
//
//  Created by Nathan Demick on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "TitleScene.h"
#import "Coin.h"
#import "GameSingleton.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <UIAlertViewDelegate>
{
    // Variables
    int difficulty;
    
    int lastCoinCount;
    int lastMultipleCount;
    
    int coinCounter;
    int multipleCounter;
    
    int currentSum;
    float timeLeft;
    
    // Current/max turns
    int maxTurns;
    int currentTurn;
    
    // If the currentQuota is less than the quotaLimit when the turn limit is over, you lose!
    int requiredQuota;
    int currentQuota;
    
    // The main coin used to check multiples -- resets every turn
    Coin *breakCoin;
    
    NSMutableArray *grid;
    NSMutableArray *selectedNumbers;
    
    // Manipulates the position of the playing grid
    CGPoint gridOffset;
    
    // Amount of extra space between coins
    int gridSpacing;
    
    // Labels
    CCLabelTTF *turnsLabel, 
               *quotaLabel, 
               *timeLeftLabel, 
               *currentSumLabel;
    
    // Hold info about window/font sizing
    CGSize window;
    int fontMultiplier;
    NSString *hdSuffix;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void)gameOver;
- (void)showMessage:(NSString *)text;
- (void)updateStatusLabels;
- (void)updateSumLabel;
- (void)updateTimerLabel;

@end
