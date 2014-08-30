//
//  StreakEngive.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/29/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "StreakEngive.h"

@interface StreakEngive ()
@property (nonatomic, strong) NSTimer *update;
@property (nonatomic) NSUInteger guideTimeLeft;

@end
@implementation StreakEngive


- (id)init
{
   self = [super init];
   if (self){
      
      self.update = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
      self.guideTimeLeft = 0;
   }
   
   return self;
}


- (void)update:(NSTimer *)sender
{
   if (self.guideTimeLeft > 0){
      --self.guideTimeLeft;
   }
}

/*
 *    Unsigned integer that keeps track of the seconds remaining
 *    the player has the guide available. Once this int is 0,
 *    the guide is turned off and remoed via delegate methods
 */
- (void)setGuideTimeLeft:(NSUInteger)guideTimeLeft
{
   _guideTimeLeft = guideTimeLeft;
   if (_guideTimeLeft == 0){
      [self.delegate guideChangedState:NO];
   }
}

/*
 *    Called by the game scene to update the engine on the
 *    current streak. The engine runs its analysis and sends
 *    messages (if applicable) back to the game scene via
 *    delegate methods
 */
- (void)updateStreak:(NSInteger)streak
{
   //turn guide on
   if (streak == 2){
      if (self.guideTimeLeft == 0){
         [self.delegate guideChangedState:YES];
      }
      self.guideTimeLeft += 10;
      
   }
}

@end
