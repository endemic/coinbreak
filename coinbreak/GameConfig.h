//
//  GameConfig.h
//  bit-break
//
//  Created by Nathan Demick on 1/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//

// 3rd generation and newer devices: Rotate using UIViewController. Rotation should be supported on iPad apps.
// TIP:
// To improve the performance, you should set this value to "kGameAutorotationNone" or "kGameAutorotationCCDirector"
#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR
#define GAME_AUTOROTATION kGameAutorotationUIViewController

// ARMv6 (1st and 2nd generation devices): Don't rotate. It is very expensive
#elif __arm__
#define GAME_AUTOROTATION kGameAutorotationNone


// Ignore this value on Mac
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#else
#error(unknown architecture)
#endif

#define kDifficultyEasy     1
#define kDifficultyMedium   2
#define kDifficultyHard     3
#define kDifficultyInsane   4

#define kTimeEasy           60
#define kTimeMedium         45
#define kTimeHard           30
#define kTimeInsane         15

#define kQuotaEasy          10
#define kQuotaMedium        20
#define kQuotaHard          30
#define kQuotaInsane        40

#define kTurnsEasy          40
#define kTurnsMedium        30
#define kTurnsHard          20
#define kTurnsInsane        10

#define kCoinTypeBreak      1
#define kCoinTypeInner      2
#define kCoinTypeOuter      3

#endif // __GAME_CONFIG_H

