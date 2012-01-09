//
//  HelloWorldLayer.m
//  bit-break
//
//  Created by Nathan Demick on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
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
        CGSize window = [CCDirector sharedDirector].winSize;
        int fontMultiplier = 1;
        
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
        
        // The "break" (center) coin
        breakCoin = [Coin createWithType:kCoinTypeBreak];
        breakCoin.position = ccp(window.width / 2, (window.height / 2) - (breakCoin.valueSprite.contentSize.height * 1.05));
        [self addChild:breakCoin z:0];
        
        // Create some temporary labels that show game progress
        turnsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Turns: %i/%i", currentTurn, maxTurns] fontName:@"Helvetica" fontSize:16.0 * fontMultiplier];
        quotaLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Quota: %i/%i", currentQuota, requiredQuota] fontName:@"Helvetica" fontSize:16 * fontMultiplier];
        timeLeftLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time Left: %f", timeLeft] fontName:@"Helvetica" fontSize:16 * fontMultiplier];
        currentSumLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Sum: %i", currentSum] fontName:@"Helvetica" fontSize:16 * fontMultiplier];
        
        [self addChild:turnsLabel];
        [self addChild:quotaLabel];
        [self addChild:timeLeftLabel];
        [self addChild:currentSumLabel];
        
        turnsLabel.position = ccp(turnsLabel.contentSize.width / 2, window.height - turnsLabel.contentSize.height / 2);
        quotaLabel.position = ccp(quotaLabel.contentSize.width / 2, turnsLabel.position.y - quotaLabel.contentSize.height);
        timeLeftLabel.position = ccp(timeLeftLabel.contentSize.width / 2, quotaLabel.position.y - timeLeftLabel.contentSize.height);
        currentSumLabel.position = ccp(currentSumLabel.contentSize.width / 2, timeLeftLabel.position.y - currentSumLabel.contentSize.height);
        
        // Arrays to hold "coin" objects
        grid = [[NSMutableArray arrayWithCapacity:16] retain];
        selectedNumbers = [[NSMutableArray array] retain];
        
        // Variables dealing w/ grid display
        int gridSize = 4;
        
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
                        c.position = ccp(i * size + gridOffset.x, j * size + gridOffset.y);
                        
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
                        c.position = ccp(i * size + gridOffset.x, j * size + gridOffset.y);
                        
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
                continue;
            }
            
            // Enforce that the touched coin was not already added to the "selected" array
            if ([selectedNumbers containsObject:c])
            {
                // TODO: Play a "bzzt" noise or show some sort of status message
                continue;
            }
            
            // Play SFX
            // [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            
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
                // Determine if any bonus multipliers are in effect
                int coinCount = [selectedNumbers count];
                int multipleCount = currentSum / breakCoin.currentValue;
                                
                if (coinCount == lastCoinCount) 
                {
                    coinCounter++;
                    // TODO: Show some sort of status message
                }
                
                if (multipleCount == lastMultipleCount)
                {
                    multipleCounter++;
                    // TODO: Show some sort of status message
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
                            [selected flash];
                            
                            // Remove the coin from the layer
                            [self removeChild:selected cleanup:YES];
                            
                            // Replace the coin in the grid with NSNull
                            [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:selected] withObject:[NSNull null]];
                            break;
                    }
                }
                
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
                            
                            [replacement flash];
                        }
                    }
                    else
                    {
                        Coin *gridCoin = [grid objectAtIndex:j];
                        
                        // Otherwise, increment the value of outer coins
                        if (gridCoin.type == kCoinTypeOuter)
                        {
                            // Remove coins that have a value of 9
                            if (gridCoin.currentValue == 9)
                            {
                                // Special effect?
                                [gridCoin flash];
                                
                                // Remove the coin from the layer
                                [self removeChild:gridCoin cleanup:YES];
                                
                                // Replace the coin in the grid with NSNull
                                NSLog(@"Removing a 9 coin");
                                [grid replaceObjectAtIndex:[grid indexOfObjectIdenticalTo:gridCoin] withObject:[NSNull null]];
                            }
                            else
                            {
                                // Increment all other coins
                                [gridCoin incrementValue];   
                            }
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
            // Go back to title screen
			break;
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
