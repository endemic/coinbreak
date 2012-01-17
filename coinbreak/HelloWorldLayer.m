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
        fontMultiplier = 1;
        hdSuffix = @"";
        
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
        
        gridOffset = ccp(36, 45);
        gridSpacing = 15;
        
        // Add background
        CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"background%@.png", hdSuffix]];
        background.position = ccp(window.width / 2, window.height / 2);
        [self addChild:background];
        
        // The "break" (center) coin
        breakCoin = [Coin createWithType:kCoinTypeBreak];
        breakCoin.position = ccp(window.width / 2, (window.height / 2) - (breakCoin.valueSprite.contentSize.height * 1.05));
        [self addChild:breakCoin z:0];
        
        // Create some temporary labels that show game progress
        turnsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Turns: %i/%i", currentTurn, maxTurns] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:48.0 * fontMultiplier];
        quotaLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Quota: %i/%i", currentQuota, requiredQuota] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:48 * fontMultiplier];
        timeLeftLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time Left: %f", timeLeft] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:48 * fontMultiplier];
        currentSumLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Sum: %i", currentSum] dimensions:CGSizeMake(160 * fontMultiplier, 90 * fontMultiplier) alignment:CCTextAlignmentLeft fontName:@"BebasNeue.otf" fontSize:48 * fontMultiplier];
        
        [self addChild:turnsLabel];
        [self addChild:quotaLabel];
        [self addChild:timeLeftLabel];
        [self addChild:currentSumLabel];
        
        // Left side
        turnsLabel.position = ccp(turnsLabel.contentSize.width / 2, window.height - turnsLabel.contentSize.height / 2);
        currentSumLabel.position = ccp(currentSumLabel.contentSize.width / 2, window.height - currentSumLabel.contentSize.height);
        
        // Right side
        quotaLabel.position = ccp(window.width - quotaLabel.contentSize.width / 2, window.height - quotaLabel.contentSize.height / 2);
        timeLeftLabel.position = ccp(window.width - timeLeftLabel.contentSize.width / 2, window.height - timeLeftLabel.contentSize.height);
        
        // Arrays to hold "coin" objects
        grid = [[NSMutableArray arrayWithCapacity:16] retain];
        selectedNumbers = [[NSMutableArray array] retain];
        
        // Variables dealing w/ grid display
        int gridSize = 4;
        
        /*
         Iterating thru the grid 0 - 15 looks like this
         
         3 7 11 15
         2 6 10 14
         1 5  9 13
         0 4  8 12
         
         I would rather it go all the way around the outside, or from top to bottom
         */
        
        // Populate the play grid with coins
        for (int i = 0; i < gridSize; i++)
        {
            for (int j = 0; j < gridSize; j++)
            {
                int index = j + i * gridSize;
                
                switch (index) 
                {
                    // Center coins
                    case 5:
                    case 6:
                    case 9:
                    case 10:
                    {
                        // Create & position coin
                        Coin *c = [Coin createWithType:kCoinTypeInner];
                        int size = c.backgroundSprite.contentSize.width + gridSpacing;
                        
                        c.position = ccp(j * size + gridOffset.x, i * size + gridOffset.y);
                        
                        // Add to layer
                        [self addChild:c z:1];
                        
                        // Add to organizational array
                        [grid insertObject:c atIndex:index];
                    }
                        break;
                    // All the rest
                    default:
                    {
                        // Create & position coin
                        Coin *c = [Coin createWithType:kCoinTypeOuter];
                        int size = c.backgroundSprite.contentSize.width + gridSpacing;
                        
                        c.position = ccp(j * size + gridOffset.x, i * size + gridOffset.y);
                        
                        // Add to layer
                        [self addChild:c z:1];
                        
                        // Add to organizational array
                        [grid insertObject:c atIndex:index];
                    }
                        break;
                }
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
                // Play sfx
                [[SimpleAudioEngine sharedEngine] playEffect:@"coin.caf"];
                
                // Display status message
                [self showMessage:@"Break!"];
                
                // Determine if any bonus multipliers are in effect
                int coinCount = [selectedNumbers count];
                int multipleCount = currentSum / breakCoin.currentValue;
                                
                if (coinCount == lastCoinCount) 
                {
                    coinCounter++;
                    // TODO: Show some sort of status message
                }
                else
                {
                    coinCounter = 0;
                }
                
                if (multipleCount == lastMultipleCount)
                {
                    multipleCounter++;
                    // TODO: Show some sort of status message
                }
                else
                {
                    multipleCounter = 0;
                }
                
                // Store previous values for next turn
                lastCoinCount = coinCount;
                lastMultipleCount = multipleCount;
                    
                // Reset the value of the break coin
                [breakCoin randomizeValue];
                
                // Reset the current sum
                currentSum = 0;
                
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
                            //[selected flash];
                            
                            // Remove the coin from the layer
                            [self removeChild:selected cleanup:YES];
                            
                            // Replace the coin in the grid with NSNull
                            [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:selected] withObject:[NSNull null]];
                            break;
                    }
                }
                
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
                                // Special effect?
                                //[gridCoin flash];
                                
                                // Remove the coin from the layer
                                [self removeChild:gridCoin cleanup:YES];
                                
                                // Replace the coin in the grid with NSNull
                                [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:gridCoin] withObject:[NSNull null]];
                            }
                            else
                            {
                                // Effect a slight delay between increment effects
                                CCDelayTime *wait = [CCDelayTime actionWithDuration:(float)(j / 10.0)];
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
                
                /*
                 Iterating thru the grid 0 - 15 looks like this
                 
                 3 7 11 15
                 2 6 10 14
                 1 5  9 13
                 0 4  8 12
                 
                 I would rather it go all the way around the outside, or from top to bottom
                 */
                
                
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
                            int size = replacement.valueSprite.contentSize.width + gridSpacing;
                            
                            replacement.position = ccp(x * size + gridOffset.x, y * size + gridOffset.y);
                            
                            // Add to layer
                            [self addChild:replacement z:1];
                            
                            // "Grow" the coin into place
                            [replacement embiggen];
                        }
                    }
                }
                
                // Update the labels that display status to the player
                [self updateStatusLabels];
                [self updateSumLabel];
                
                // Remove all coins in the "selected" array
                [selectedNumbers removeAllObjects];
                
                // If the current turn == max turn, game over!
                if (currentTurn == maxTurns)
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
- (void)showMessage:(NSString *)text
{
    // Create/add label
    CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:@"BebasNeue.otf" fontSize:44 * fontMultiplier];
    label.position = ccp(window.width / 2, window.height / 2 - label.contentSize.height);
    [self addChild:label z:3];

    // Move/fade the "Break!" text into place, and enable layer touch when finished
    id move = [CCMoveTo actionWithDuration:0.4 position:ccp(window.width / 2, window.height / 2 - label.contentSize.height)];
    id ease = [CCEaseBackOut actionWithAction:move];
    id fadeIn = [CCFadeIn actionWithDuration:0.3];
    id wait = [CCDelayTime actionWithDuration:0.8];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node.parent removeChild:node cleanup:YES];
    }];
    id enableTouch = [CCCallBlock actionWithBlock:^{
        //[self setIsTouchEnabled:YES];
    }];
    
    // Run fade in/fade out animation on text
    [label runAction:[CCSequence actions:[CCSpawn actions:ease, fadeIn, nil], wait, fadeOut, remove, enableTouch, nil]];
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
    timeLeftLabel.string = [NSString stringWithFormat:@"Time Left: %f2", timeLeft];
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
