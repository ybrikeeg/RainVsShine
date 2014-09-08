//
//  StreakEngive.h
//  RainVsShine
//
//  Created by Kirby Gee on 8/29/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreakEngineDelegate <NSObject>

@optional
@required
- (void)guideChangedToState:(BOOL)active;
- (void)largeBulletChangedToState:(BOOL)active;
- (void)multiplierChangedToValue:(NSUInteger)multiplier;
@end

@interface StreakEngive : NSObject

@property (nonatomic, weak) id <StreakEngineDelegate> delegate;
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) UILabel *largeBulletLabel;



- (void)updateStreak:(NSInteger)streak;
- (void)bulletFired;
@end
