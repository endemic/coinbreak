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
        CGSize window = [CCDirector sharedDirector].winSize;
        int fontMultiplier = 1;
        
        // Create a title graphic
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Coin Break" fontName:@"Helvetica" fontSize:64 * fontMultiplier];
        title.position = ccp(window.width / 2, window.height - title.contentSize.height);
        [self addChild:title];
        
        // Create four buttons to choose difficulty levels and transition to HelloWorldLayer
        CCMenuItemFont *easyButton = [CCMenuItemFont itemFromString:@"Easy" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyEasy;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *mediumButton = [CCMenuItemFont itemFromString:@"Normal" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyMedium;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *hardButton = [CCMenuItemFont itemFromString:@"Hard" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyHard;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenuItemFont *insaneButton = [CCMenuItemFont itemFromString:@"Insane" block:^(id sender) {
            [GameSingleton sharedGameSingleton].difficulty = kDifficultyInsane;
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[HelloWorldLayer node]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems: easyButton, mediumButton, hardButton, insaneButton, nil];
        menu.position = ccp(window.width / 2, title.position.y - easyButton.contentSize.height * 4);
        [menu alignItemsVerticallyWithPadding:10.0];
        [self addChild:menu];
        
        return self;
    }
    return nil;
}
@end
