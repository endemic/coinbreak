//
//  Coin.m
//  bit-break
//
//  Created by Nathan Demick on 1/4/12.
//  Copyright 2012 Ganbaru Games. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@synthesize type, currentValue, valueSprite, backgroundSprite, width, height;

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
    c.valueSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-value.png", c.currentValue]];
    c.backgroundSprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i-type.png", c.type]];
    
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
    
    // Change the displayed number sprite
    valueSprite.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%i-value.png", currentValue]];
    
    // Should probably be some sort of graphical effect here
    [self flash];
}

/**
 * Used exclusively by the "break" coin after every turn
 */
- (void)randomizeValue
{
    // Set the current value
    currentValue = (float)(arc4random() % 100) / 100 * 8 + 1; // 1-9
    
    // Change the displayed number sprite
    valueSprite.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"%i-value.png", currentValue]];    
    
    // Graphical effect!
    [self flash];
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
 * Create a particle effect on the coin
 */
- (void)flash
{
    CGPoint position = ccp(0, 0);
	int particleCount = 500;
	
	// Create quad particle system (faster on 3rd gen & higher devices, only slightly slower on 1st/2nd gen)
	CCParticleSystemQuad *particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:particleCount];
	
	[particleSystem setEmitterMode:kCCParticleModeGravity];
    [particleSystem setDuration:0.2];
	
	// Gravity Mode: gravity
	[particleSystem setGravity:ccp(0, 0)];
	
	// Gravity Mode: speed of particles
	[particleSystem setSpeed:140];
	[particleSystem setSpeedVar:40];
	
	// Gravity Mode: radial
	[particleSystem setRadialAccel:0];
	[particleSystem setRadialAccelVar:0];
	
	// Gravity Mode: tagential
	[particleSystem setTangentialAccel:0];
	[particleSystem setTangentialAccelVar:0];
	
	// angle
	[particleSystem setAngle:90];
	[particleSystem setAngleVar:360];
	
	// emitter position
	[particleSystem setPosition:position];
	[particleSystem setPosVar:CGPointZero];
	
	// life is for particles particles - in seconds
	[particleSystem setLife:0];
	[particleSystem setLifeVar:0.4];
	
	// size, in pixels
	[particleSystem setStartSize:10.0 * fontMultiplier];
	[particleSystem setStartSizeVar:5.0 * fontMultiplier];
	[particleSystem setEndSize:20.0 * fontMultiplier];
    [particleSystem setEndSizeVar:5.0 * fontMultiplier];
	
	// emits per second
	[particleSystem setEmissionRate:[particleSystem totalParticles] / [particleSystem duration]];
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 0.25f};
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 0.75f};
	[particleSystem setStartColor:startColor];
	[particleSystem setEndColor:endColor];
	
    // Set the texture
    [particleSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"particle%@.png", hdSuffix]]];

	// additive
	[particleSystem setBlendAdditive:YES];
	
	// Auto-remove the emitter when it is done!
	[particleSystem setAutoRemoveOnFinish:YES];
	
	// Add to layer
	[self addChild:particleSystem z:5];
}

@end
