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
- (void)guideChangedState:(BOOL)active;
@end

@interface StreakEngive : NSObject

@property (nonatomic, weak) id <StreakEngineDelegate> delegate;


- (void)updateStreak:(NSInteger)streak;
@end
