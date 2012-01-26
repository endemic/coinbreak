//
//  HelloWorldLayer.m
//  bit-break
//
//  Created by Nathan Demick on 1/3/12.
//  Copyright Ganbaru Games 2012. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+ (CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
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
        
        // Set variables based on set difficulty
        switch ([GameSingleton sharedGameSingleton].difficulty) 
        {
            default:
            case kDifficultyEasy:
                difficulty = kDifficultyEasy;
                timeLeft = kTimeEasy;
                requiredQuota = kQuotaEasy;
                maxTurns = kTurnsEasy;
                break;
            case kDifficultyMedium:
                difficulty = kDifficultyMedium;
                timeLeft = kTimeMedium;
                requiredQuota = kQuotaMedium;
                maxTurns = kTurnsMedium;
                break;
            case kDifficultyHard:
                difficulty = kDifficultyHard;
                timeLeft = kTimeHard;
                requiredQuota = kQuotaHard;
                maxTurns = kTurnsHard;
                break;
            case kDifficultyInsane:
                difficulty = kDifficultyInsane;
                timeLeft = kTimeInsane;
                requiredQuota = kQuotaInsane;
                maxTurns = kTurnsInsane;
                break;
        }

        lastCoinCount = 0;
        lastMultipleCount = 0;
        
        coinCounter = 0;
        multipleCounter = 0;
        
        currentSum = 0;
        currentTurn = 0;
        currentQuota = 0;
        
        gridOffset = ccp(40, 115);
        gridSpacing = [GameSingleton sharedGameSingleton].isPad ? 30 : 15;
        coinSize = [GameSingleton sharedGameSingleton].isPad ? 125 : 66;
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
        background.position = ccp(window.width / 2, window.height / 2);
        [self addChild:background];
        
        // Add the outline of the grid
        CCSprite *outline = [CCSprite spriteWithFile:[NSString stringWithFormat:@"grid-outline%@.png", hdSuffix]];
        outline.position = ccp(window.width / 2, window.height / 2);
        [self addChild:outline];
        
        // Create some labels that show game progress
        int labelFontSize = 36;
        turnsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Turn: %i/%i", currentTurn, maxTurns] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:labelFontSize * fontMultiplier];
        quotaLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Quota: %i/%i", currentQuota, requiredQuota] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:labelFontSize * fontMultiplier];
        
        currentSumLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Sum: %i", currentSum] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:labelFontSize * fontMultiplier];
        nextMultipleLabel = [CCLabelTTF labelWithString:@"Next: ~" dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:labelFontSize * fontMultiplier];
        
        timeLeftLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time Left: %f", timeLeft] dimensions:CGSizeMake(200 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:labelFontSize * fontMultiplier];
        
        [self addChild:turnsLabel];
        [self addChild:quotaLabel];
        [self addChild:currentSumLabel];
        [self addChild:nextMultipleLabel];
        [self addChild:timeLeftLabel];
        
        // Left side
        turnsLabel.position = ccp(turnsLabel.contentSize.width / 2, window.height - turnsLabel.contentSize.height / 2);
        currentSumLabel.position = ccp(currentSumLabel.contentSize.width / 2, window.height - currentSumLabel.contentSize.height);
        
        // Right side
        quotaLabel.position = ccp(window.width - quotaLabel.contentSize.width / 2, window.height - quotaLabel.contentSize.height / 2);
        nextMultipleLabel.position = ccp(window.width - nextMultipleLabel.contentSize.width / 2, window.height - nextMultipleLabel.contentSize.height);
        
        // Bottom
        timeLeftLabel.position = ccp(window.width / 2, timeLeftLabel.contentSize.height / 3);
        
        // The "break" (center) coin
        breakCoin = [Coin createWithType:kCoinTypeBreak];
        breakCoin.position = ccp(window.width / 2, window.height / 2);
        [self addChild:breakCoin z:0];
        
        // Arrays to hold "coin" objects
        grid = [[NSMutableArray arrayWithCapacity:16] retain];
        selectedNumbers = [[NSMutableArray array] retain];
        
        // Variables dealing w/ grid display
        int gridSize = 4;
        
        /*
         grid currently looks like this
         
         13 14 15 16
          9 10 11 12
          5  6  7  8
          1  2  3  4
         
         I would rather it go all the way around the outside, or from top to bottom
         */
        
        // Populate the play grid with coins
        for (int i = 0; i < gridSize; i++)
        {
            for (int j = 0; j < gridSize; j++)
            {
                int index = j + i * gridSize;
                
                Coin *c;
                
                // Inner coins
                if (index == 5 || index == 6 || index == 9 || index == 10)
                {
                    c = [Coin createWithType:kCoinTypeInner];
                }
                else 
                {
                    c = [Coin createWithType:kCoinTypeOuter];
                }
                
                // Position
                c.position = ccp(j * (coinSize + gridSpacing) + gridOffset.x, i * (coinSize + gridSpacing) + gridOffset.y);
                
                // Add to layer
                [self addChild:c z:2];
                
                // Add to organizational array
                [grid insertObject:c atIndex:index];
                
                // Also add sprites that denote empty spaces - these don't have to be referenced later
                CCSprite *empty = [CCSprite spriteWithFile:[NSString stringWithFormat:@"empty-spot%@.png", hdSuffix]];
                empty.position = ccp(j * (coinSize + gridSpacing) + gridOffset.x, i * (coinSize + gridSpacing) + gridOffset.y);
                [self addChild:empty z:1];
            }
        }
        
        // Enable touch for layer
        [self setIsTouchEnabled:YES];
        
        // Schedule update method
        [self schedule:@selector(update:) interval:0.1];
	}
	return self;
}

/**
 * Update method
 */
- (void)update:(ccTime)dt
{
    // Count down the timer
    timeLeft -= dt;
    
    [self updateTimerLabel];
    
    // If timer < 0, game is over!
    if (timeLeft < 0)
    {
        // Set the timer to zero so it looks nicer
        timeLeft = 0;
        [self updateTimerLabel];
        
        [self gameOver];
    }
}

/**
 * Take action after the player touches the game board 
 */
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Determine which number was touched, and add it to the list of "active" numbers
    // If the sum is a clean multiple, a "break" occurs
    // Determine the # of "coins" used for the break; if it's the same as the previous turn, add an "echo" bonus
    // Determine the multiple of the break; if it's the same as the previous turn, add a "multiplier" bonus
    // Clear the selected outer numbers, add the # to currentQuota
    // Randomly add new numbers to empty outer number slots
    // Otherwise, animate the selected number and add its' sum to the total
    
    // Get the touch coords
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
    
    // Loop thru them to determine whether the touch was within any of their bounds
	for (int i = 0; i < [grid count]; i++)
	{
        // Skip empty coin spots in the grid
        if ([grid objectAtIndex:i] == [NSNull null])
        {
            continue;
        }
        
		Coin *c = [grid objectAtIndex:i];
		
		// CGRect origin is at 0, 0, not midpoint
        // Since the sprite is square, we can use the same "size" variable for both width and height
        int size = c.backgroundSprite.contentSize.width;
		CGRect spriteBounds = CGRectMake(c.position.x - (size / 2), c.position.y - (size / 2), size, size);
		CGRect touchBounds = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);		// 1x1 square
		
		// If the touch point is inside the bounds of a coin...
		if (CGRectIntersectsRect(spriteBounds, touchBounds))
		{
            // Enforce that the first coin touched is a "center" coin
            if (currentSum == 0 && c.type != kCoinTypeInner)
            {
                // TODO: Play a "bzzt" noise or show some sort of status message
                [[SimpleAudioEngine sharedEngine] playEffect:@"beep.caf"];
                continue;
            }
            
            // Enforce that the touched coin was not already added to the "selected" array
            if ([selectedNumbers containsObject:c])
            {
                // TODO: Play a "bzzt" noise or show some sort of status message
                [[SimpleAudioEngine sharedEngine] playEffect:@"beep.caf"];
                continue;
            }
            
            // Play SFX
            [[SimpleAudioEngine sharedEngine] playEffect:@"tick.caf"];
            
            // Add touched coin to the list of selected coins
            [selectedNumbers addObject:c];
            
            // Increment the total sum
            currentSum += c.currentValue;
            
            [self updateSumLabel];
            
            // If sum is multiple of break coin, a "break" occurs and we remove the selected outer coins, 
            // adding the total of removed coins to the quota
            
            // Remainder of 0 means the sum is a clean multiple
            if (currentSum % breakCoin.currentValue == 0)
            {
                // Disable additional player input until the status messages disappear
                [self setIsTouchEnabled:NO];
                
                // Play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:@"coin.caf"];
                
                // Determine if any bonus multipliers are in effect
                int coinCount = [selectedNumbers count];
                int multipleCount = currentSum / breakCoin.currentValue;
                
                // Create array of strings to show user
                NSMutableArray *messages = [NSMutableArray arrayWithObject:@"Break!"]; 
                
                if (coinCount == lastCoinCount) 
                {
                    coinCounter++;
                    [messages addObject:[NSString stringWithFormat:@"Count Bonus x%i!", coinCount]];
                }
                else
                {
                    coinCounter = 0;
                }
                
                if (multipleCount == lastMultipleCount)
                {
                    multipleCounter++;
                    [messages addObject:[NSString stringWithFormat:@"Multiple Bonus x%i!", multipleCounter]];
                }
                else
                {
                    multipleCounter = 0;
                }
                
                // Display status messages
                [self showMessage:messages];
                
                // Store previous values for next turn
                lastCoinCount = coinCount;
                lastMultipleCount = multipleCount;
                    
                // Reset the value of the break coin
                [breakCoin randomizeValue];
                
                // Reset the current sum
                currentSum = 0;
                nextMultiple = 0;
                
                // Increment the current turn
                currentTurn++;
                
                // Reset the turn timer
                switch (difficulty) 
                {
                    default:
                    case kDifficultyEasy:
                        timeLeft = kTimeEasy;
                        break;
                    case kDifficultyMedium:
                        timeLeft = kTimeMedium;
                        break;
                    case kDifficultyHard:
                        timeLeft = kTimeHard;
                        break;
                    case kDifficultyInsane:
                        timeLeft = kTimeInsane;
                        break;
                }
                
                // Cycle through the selectedNumbers array, removing any "outer" coins
                for (int j = 0; j < [selectedNumbers count]; j++)
                {
                    Coin *selected = [selectedNumbers objectAtIndex:j];
                    switch (selected.type) 
                    {
                        case kCoinTypeInner:
                            // Stop the spin!
                            [selected stop];
                            break;
                        case kCoinTypeOuter:
                            // Increase score
                            currentQuota += 1 + coinCounter + multipleCounter;
                            
                            // Special effect?
                            [self explosionAt:selected.position];
                            
                            // Remove the coin from the layer
                            [self removeChild:selected cleanup:YES];
                            
                            // Replace the coin in the grid with NSNull
                            [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:selected] withObject:[NSNull null]];
                            break;
                    }
                }
                
                // Remove all coins in the "selected" array
                [selectedNumbers removeAllObjects];
                
                // Increment values of existing coins
                for (int j = 0; j < [grid count]; j++)
                {
                    if ([grid objectAtIndex:j] != [NSNull null])
                    {
                        Coin *gridCoin = [grid objectAtIndex:j];
                        
                        // Only increment "outer" coins
                        if (gridCoin.type == kCoinTypeOuter)
                        {
                            // Remove coins that have a value of 9
                            if (gridCoin.currentValue == 9)
                            {
                                // Shrink coin out then remove from layer
                                CCScaleTo *scale = [CCScaleTo actionWithDuration:0.5 scale:0];
                                CCEaseBackIn *ease = [CCEaseBackIn actionWithAction:scale];
                                CCCallBlockN *remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                    // Remove the coin from the layer
                                    [self removeChild:(Coin *)node cleanup:YES];
                                }];
                                [gridCoin runAction:[CCSequence actions:ease, remove, nil]];

                                // Replace the coin in the grid with NSNull
                                [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:gridCoin] withObject:[NSNull null]];
                            }
                            else
                            {
                                // Effect a slight delay between increment effects
                                CCDelayTime *wait = [CCDelayTime actionWithDuration:(float)j / (float)[grid count]];     // Max time: 1 second
                                CCCallBlockN *increment = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                    // Increment all other coins
                                    [(Coin *)node incrementValue];
                                }];
                                
                                // run actions
                                [gridCoin runAction:[CCSequence actions:wait, increment, nil]];
                            }
                        }
                    }
                }
                
                CCCallBlock *randomlyAddNewCoins = [CCCallBlock actionWithBlock:^{
                    // Randomly re-insert coins into any empty grid spaces
                    for (int j = 0; j < [grid count]; j++)
                    {
                        if ([grid objectAtIndex:j] == [NSNull null])
                        {
                            // Randomly decide to insert or not
                            if (CCRANDOM_MINUS1_1() > 0)    // returns -1 ~ 1
                            {
                                Coin *replacement = [Coin createWithType:kCoinTypeOuter];
                                
                                // Replace in grid
                                [grid replaceObjectAtIndex:j withObject:replacement];
                                
                                // Set position
                                int x = j / 4;
                                int y = j % 4;
                                
                                replacement.position = ccp(y * (coinSize + gridSpacing) + gridOffset.x, x * (coinSize + gridSpacing) + gridOffset.y);
                                
                                // Add to layer
                                [self addChild:replacement z:1];
                                
                                // "Grow" the coin into place
                                [replacement embiggen];
                            }
                        }
                    }
                }];
                
                // Randomly add new coins after a delay to wait for the "incrment" effect to occur
                [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0], randomlyAddNewCoins, nil]];
                
                // Update the labels that display status to the player
                [self updateStatusLabels];
                [self updateSumLabel];
                
                // If the current turn == max turn, game over!
                if (currentTurn == maxTurns || currentQuota >= requiredQuota)
                {
                    [self gameOver];
                }
            }
            // If a break hasn't been made yet, just rotate the coin to indicate it's been selected
            else
            {
                // Rotate the coin
                [c spin];
            }
			break;
		}
	}
}

/**
 * Game over method; compare quotas to see if the player won or not
 */
- (void)gameOver
{
    // Stop the timer
    [self unschedule:@selector(update:)];
    
    // Determine if win conditions were met
    if (currentQuota < requiredQuota)
    {
        // You lose!
        CCLOG(@"YOU LOSE");
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"YOU LOSE"
                                                             message:@"Try harder, buddy!"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
    else
    {
        // You win!
        CCLOG(@"YOU WIN!");
        
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"YOU WIN"
                                                             message:@"Congratulations!"
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
        [alertView show];
    }
}

/**
 * Handle clicking of the alert view
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) 
	{
		default:
        {
            // Go back to title screen
            CCTransitionMoveInL *transition = [CCTransitionMoveInL transitionWithDuration:0.5 scene:[TitleScene scene]];
            [[CCDirector sharedDirector] replaceScene:transition];
        }
			break;
    }
}

/**
 * Pops up a label w/ some text
 */
- (void)showMessage:(NSMutableArray *)messages
{
    // Fade in background
    CCSprite *bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"message-background%@.png", hdSuffix]];
    bg.position = ccp(window.width / 2, window.height / 2);
    bg.opacity = 0;
    [self addChild:bg z:3];
    
    [bg runAction:[CCFadeIn actionWithDuration:0.5]];
    
    // Slide the label into place, and enable layer touch when finished
    id moveIn = [CCMoveTo actionWithDuration:0.4 position:ccp(window.width / 2, window.height / 2)];
    id easeIn = [CCEaseBackOut actionWithAction:moveIn];
    id moveOut = [CCMoveTo actionWithDuration:0.4 position:ccp(window.width * 1.5, window.height / 2)];
    id easeOut = [CCEaseBackIn actionWithAction:moveOut];
    
    id wait = [CCDelayTime actionWithDuration:0.8];

    id remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node.parent removeChild:node cleanup:YES];
    }];
    
    id enableTouch = [CCCallBlock actionWithBlock:^{
        [self setIsTouchEnabled:YES];
    }];
    
    // Make the background fade out and remove itself after all messages are shown - 1.6 seconds is total animation time for text
    id fadeOut = [CCFadeOut actionWithDuration:0.3];
    id bgWait = [CCDelayTime actionWithDuration:[messages count] * 1.6];
    [bg runAction:[CCSequence actions:bgWait, fadeOut, remove, nil]];
    
    for (int i = 0; i < [messages count]; i++)
    {
        // Create/add labels
        CCLabelTTF *label = [CCLabelTTF labelWithString:[messages objectAtIndex:i] fontName:@"BebasNeue.otf" fontSize:44 * fontMultiplier];
        label.position = ccp(-label.contentSize.width / 2, window.height / 2);
        [self addChild:label z:4];
        
        // Run fade in/fade out animation on text
        if (i < [messages count] - 1)
        {
            // More messages to come
            [label runAction:[CCSequence actions:[CCDelayTime actionWithDuration:i * 1.6], easeIn, wait, easeOut, remove, nil]];
        }
        else
        {
            // Enable touches again on the last message
            [label runAction:[CCSequence actions:[CCDelayTime actionWithDuration:i * 1.6], easeIn, wait, easeOut, remove, enableTouch, nil]];
        }
    }
}

/**
 * Methods to update some levels
 */
- (void)updateStatusLabels
{
    turnsLabel.string = [NSString stringWithFormat:@"Turns: %i/%i", currentTurn, maxTurns];
    quotaLabel.string = [NSString stringWithFormat:@"Quota: %i/%i", currentQuota, requiredQuota];
}

- (void)updateSumLabel
{
    currentSumLabel.string = [NSString stringWithFormat:@"Sum: %i", currentSum];
}

- (void)updateTimerLabel
{
    timeLeftLabel.string = [NSString stringWithFormat:@"Time Left: %.1f", timeLeft];
}

- (void)explosionAt:(CGPoint)position
{
	int particleCount = 200;
	
	// Create quad particle system (faster on 3rd gen & higher devices, only slightly slower on 1st/2nd gen)
	CCParticleSystemQuad *particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:particleCount];
	
	[particleSystem setEmitterMode:kCCParticleModeGravity];
    [particleSystem setDuration:0.1];
	
	// Gravity Mode: gravity
	[particleSystem setGravity:ccp(0, -200)];
	
	// Gravity Mode: speed of particles
	[particleSystem setSpeed:100];
	[particleSystem setSpeedVar:30];
	
	// angle
	[particleSystem setAngle:90];
	[particleSystem setAngleVar:270];
	
	// emitter position
	[particleSystem setPosition:position];
	[particleSystem setPosVar:CGPointZero];
	
	// life is for particles particles - in seconds
	[particleSystem setLife:0.2];
	[particleSystem setLifeVar:0.6];
	
	// size, in pixels
	[particleSystem setStartSize:20.0 * fontMultiplier];
	[particleSystem setStartSizeVar:2.0 * fontMultiplier];
	[particleSystem setEndSize:0];
	
	// emits per second
	[particleSystem setEmissionRate:[particleSystem totalParticles] / [particleSystem duration]];
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
    ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 1.0f};
	ccColor4F endColor = {1.0f, 1.0f, 1.0f, 1.0f};
	[particleSystem setStartColor:startColor];
    [particleSystem setStartColorVar:startColorVar];
	[particleSystem setEndColor:endColor];
	
    // Set the texture
    [particleSystem setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"particle%@.png", hdSuffix]]];
    
	// additive
	[particleSystem setBlendAdditive:YES];
	
	// Auto-remove the emitter when it is done!
	[particleSystem setAutoRemoveOnFinish:YES];
	
    //CCLOG(@"Adding particle system at %f, %f", position.x, position.y);
    
	// Add to layer
	[self addChild:particleSystem z:5];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [grid release];
    [selectedNumbers release];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
