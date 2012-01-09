//
//  Coin.h
//  bit-break
//
//  Created by Nathan Demick on 1/4/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//
//  Display a numeric "coin" with a background

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSingleton.h"

@interface Coin : CCNode 
{
    // Sprites
    CCSprite *backgroundSprite;
    CCSprite *valueSprite;
    
    // Easy way to access the value of the coint
    int currentValue;
    
    // The "type" of coin: break, inner, outer (0, 1, and 2, respectively)
    int type;
    
    // Determine HD/SD nonsense
    NSString *hdSuffix;
    int fontMultiplier;
    
    // Helpers for width/height
    int width;
    int height;
}

+ (Coin *)createWithType:(int)type;
- (void)incrementValue;
- (void)randomizeValue;
- (void)spin;
- (void)stop;
- (void)flash;

@property (nonatomic, retain) CCSprite *backgroundSprite;
@property (nonatomic, retain) CCSprite *valueSprite;
@property (nonatomic) int currentValue;
@property (nonatomic) int type;
@property (nonatomic) int width;
@property (nonatomic) int height;

@end
