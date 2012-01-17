//
//  TitleScene.m
//  bit-break
//
//  Created by Nathan Demick on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleScene.h"


@implementation TitleScene
+ (CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleScene *layer = [TitleScene node];
	
	// add layer as a child to scene
	[scene addChild:layer];

	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	if ((self = [super init])) 
    {
        // Store window size
        window = [CCDirector sharedDirector].winSize;
        fontMultiplier = 1;
        hdSuffix = @"";
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
        background.position = ccp(window.width / 2, window.height / 2);
        [self addChild:background z:0];
        
        // Create a title graphic
        CCSprite *logo = [CCSprite spriteWithFile:[NSString stringWithFormat:@"logo%@.png", hdSuffix]];
        logo.position = ccp(window.width / 2, window.height - logo.contentSize.height / 1.5);
        [self addChild:logo z:2];
        
        // Create falling coins behind title
        //[self createParticleSystem];
        
        [CCMenuItemFont setFontName:@"BebasNeue.otf"];
        [CCMenuItemFont setFontSize:44 * fontMultiplier];
        
        
/*        
        // Create four buttons to choose difficulty levels and transition to HelloWorldLayer
        CCMenuItemFont *easyButton = [CCMenuItemFont itemFromString:@"(easy)" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyEasy;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *mediumButton = [CCMenuItemFont itemFromString:@"(normal)" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyMedium;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *hardButton = [CCMenuItemFont itemFromString:@"(hard)" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyHard;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *insaneButton = [CCMenuItemFont itemFromString:@"(insane)" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyInsane;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
*/
        
        CCMenuItemFont *playButton = [CCMenuItemFont itemFromString:@"(play)" block:^(id sender) {
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
            
            // Set difficulty
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyMedium;
            
            // Transition to game scene
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *statsButton = [CCMenuItemFont itemFromString:@"(stats)" block:^(id sender) {
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
            
            // Set difficulty
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyMedium;
            
            // Transition to game scene
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *helpButton = [CCMenuItemFont itemFromString:@"(help)" block:^(id sender) {
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
            
            // Set difficulty
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyMedium;
            
            // Transition to game scene
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems: playButton, statsButton, helpButton, nil];
        menu.position = ccp(window.width / 2, window.height / 3);
        [menu alignItemsVerticallyWithPadding:5.0 * fontMultiplier];
        [self addChild:menu z:2];
        
        [CCMenuItemFont setFontSize:20 * fontMultiplier];
        
        // Set up Ganbaru Games text
        CCMenuItemFont *copyrightButton = [CCMenuItemFont itemFromString:@"©2012 ganbaru games" block:^(id sender) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://ganbarugames.com/"]];
        }];
        
        CCMenu *copyrightMenu = [CCMenu menuWithItems: copyrightButton, nil];
        copyrightMenu.position = ccp(window.width / 2, copyrightButton.contentSize.height * 1.2);
        [self addChild:copyrightMenu z:2];
        
        return self;
    }
    return nil;
}

- (void)createParticleSystem
{
    CGPoint position = ccp(window.width / 2, window.height / 2);
	int particleCount = 54;
	
	// Create quad particle system (faster on 3rd gen & higher devices, only slightly slower on 1st/2nd gen)
	CCParticleSystemQuad *particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:particleCount];
	
	[particleSystem setEmitterMode:kCCParticleModeGravity];
    [particleSystem setDuration:-1.0];
	
	// Gravity Mode: gravity
	[particleSystem setGravity:ccp(0, -800)];
	
	// Gravity Mode: speed of particles
	[particleSystem setSpeed:375];
	[particleSystem setSpeedVar:40];
	
	// Gravity Mode: radial
	[particleSystem setRadialAccel:0];
	[particleSystem setRadialAccelVar:0];
	
	// Gravity Mode: tagential
	[particleSystem setTangentialAccel:0];
	[particleSystem setTangentialAccelVar:0];
	
	// angle
	[particleSystem setAngle:90];
	[particleSystem setAngleVar:45];
	
	// emitter position
	[particleSystem setPosition:position];
	[particleSystem setPosVar:CGPointZero];
	
	// life is for particles particles - in seconds
	[particleSystem setLife:0];
	[particleSystem setLifeVar:0.4];
	
	// size, in pixels
	[particleSystem setStartSize:62.5 * fontMultiplier];
	[particleSystem setStartSizeVar:5.0 * fontMultiplier];
	[particleSystem setEndSize:kParticleStartSizeEqualToEndSize];
	
	// emits per second
    [particleSystem setEmissionRate:1.0];
//	[particleSystem setEmissionRate:[particleSystem totalParticles] / [particleSystem duration]];
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 0.0f};
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 0.5f};
	[particleSystem setStartColor:startColor];
	[particleSystem setEndColor:endColor];
	
    // Set the texture
    [particleSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"2-type%@.png", hdSuffix]]];
    
	// additive
	[particleSystem setBlendAdditive:YES];
	
	// Auto-remove the emitter when it is done!
	[particleSystem setAutoRemoveOnFinish:YES];
	
	// Add to layer
	[self addChild:particleSystem z:1];
}
@end
