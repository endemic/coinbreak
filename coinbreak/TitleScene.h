//
//  TitleScene.h
//  bit-break
//
//  Created by Nathan Demick on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameConfig.h"
#import "GameSingleton.h"
#import "HelloWorldLayer.h"

@interface TitleScene : CCLayer <UIAlertViewDelegate>
{
    CGSize window;
    int fontMultiplier;
    NSString *hdSuffix;
}

+ (CCScene *)scene;
- (void)createParticleSystem;

@end
