//
//  Coin.m
//  bit-break
//
//  Created by Nathan Demick on 1/4/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@synthesize type, currentValue, valueSprite, backgroundSprite, width, height, fontMultiplier, hdSuffix;

/**
 * Init method; not sure if this will do anything or not
 */
- (id)init
{
    if ((self = [super init]))
    {
        // Set "fontMultiplier" and "hdSuffix" vars
        if ([GameSingleton sharedGameSingleton].isPad)
		{
			hdSuffix = @"-hd";
			fontMultiplier = 2;
		}
		else
		{
			hdSuffix = @"";
			fontMultiplier = 1;
		}
    }
    return self;
}

/**
 * Convenience method to create a 
 */
+ (Coin *)createWithType:(int)type
{
    // Create the coin
    Coin *c = [Coin node];
    
    // Set its' value
    c.currentValue = (float)(arc4random() % 100) / 100 * 8 + 1; // 1-9
    
    // Set its' type
    c.type = type;
    
    // Set the value and background sprites
    c.valueSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-value%@.png", c.currentValue, c.hdSuffix]];
    c.backgroundSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-type%@.png", c.type, c.hdSuffix]];
    
    // Set width/height convenience properties
    c.width = c.valueSprite.contentSize.width;
    c.height = c.valueSprite.contentSize.height;
    
    // Add sprites to "coin" node
    [c addChild:c.backgroundSprite z:0];
    [c addChild:c.valueSprite z:1];
    
    return c;
}

/**
 * Increments the value of a coin; run on each existing coin after every turn
 */
- (void)incrementValue
{
    // Set the current value
    currentValue++;
    
    // Should probably be some sort of graphical effect here
    [self flash];
    
    // Change the displayed number sprite
    valueSprite.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%i-value%@.png", currentValue, hdSuffix]];
}

/**
 * Used exclusively by the "break" coin after every turn
 */
- (void)randomizeValue
{
    // Set the current value
    currentValue = (float)(arc4random() % 100) / 100 * 8 + 1; // 1-9
    
    // Graphical effect!
    [self flash];
    
    // Change the displayed number sprite
    valueSprite.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%i-value%@.png", currentValue, hdSuffix]];
}

/**
 * Easy way to start a spin animation
 */
- (void)spin
{
    CCOrbitCamera *one = [CCOrbitCamera actionWithDuration:1.0 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:90 angleX:0 deltaAngleX:0];
    CCOrbitCamera *two = [CCOrbitCamera actionWithDuration:1.0 radius:1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:0 deltaAngleX:0];
    [self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:one, two, nil]]];
}

/**
 * Easy way to stop all animations
 */
- (void)stop
{
    [self stopAllActions];
    
    // Try to reset
    [self runAction:[CCOrbitCamera actionWithDuration:0 radius:1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:0 deltaAngleX:0]];
}

/**
 * Create an expanding "flash" effect
 */
- (void)flash
{
    // Create sprite
    CCSprite *s = [CCSprite spriteWithFile:[NSString stringWithFormat:@"ring-effect%@.png", hdSuffix]];
    s.position = ccp(0, 0);
    [self addChild:s z:2];
    
    // Set scale a quarter
    s.scale = 0.25;
    
    // Animate scale to 100, then remove from scene
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.5 scale:1.2];
    CCFadeTo *fade = [CCFadeTo actionWithDuration:0.6 opacity:0];
    CCCallBlockN *remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [self removeChild:node cleanup:NO];
    }];
    
    // Run actions
    [s runAction:[CCSequence actions:[CCSpawn actions:scale, fade, nil], remove, nil]];
}

/**
 * Create a "growing" effect
 */
- (void)embiggen
{
    self.scale = 0;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:1.0];
    CCEaseBackOut *ease = [CCEaseBackOut actionWithAction:scale];
    [self runAction:ease];
}

- (void)shrink
{
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.5 scale:0];
    CCEaseBackIn *ease = [CCEaseBackIn actionWithAction:scale];
    [self runAction:ease];
}

@end
