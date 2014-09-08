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
@property (nonatomic) NSUInteger largeBulletsLeft;
@end


@implementation StreakEngive


- (id)init
{
   self = [super init];
   if (self){
      self.update = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
      self.guideTimeLeft = 0;
      self.largeBulletsLeft = 0;
   }
   
   return self;
}


/*
 *    Called every second to update streak variables that control
 *    how much time the play has left with a given streak
 */
- (void)update:(NSTimer *)sender
{
   if (self.guideTimeLeft > 0){
      --self.guideTimeLeft;
   }
   
   self.guideLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.guideTimeLeft];
}

-(void)setLargeBulletsLeft:(NSUInteger)largeBulletsLeft
{
   _largeBulletsLeft = largeBulletsLeft;
   if (_largeBulletsLeft == 0){
      [self.delegate largeBulletChangedToState:NO];
   }
   
   self.largeBulletLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_largeBulletsLeft];
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
      [self.delegate guideChangedToState:NO];
   }
}

#pragma mark - Called from GameScene
/*
 *    Called every time a bullet is fired
 */
- (void)bulletFired
{
   if (self.largeBulletsLeft > 0){
      --self.largeBulletsLeft;
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
   
   if (streak == 0){
      [self.delegate multiplierChangedToValue:1];
   } else if (streak == 5){
      [self.delegate multiplierChangedToValue:2];
   } else if (streak == 10){
      [self.delegate multiplierChangedToValue:3];
   }
   if (streak == 20){//turn guide on for 10 seconds
      if (self.guideTimeLeft == 0){
         [self.delegate guideChangedToState:YES];
      }
      self.guideTimeLeft += 10;
   } else if (streak == 10){//large bullet (5 shots)
      if (self.largeBulletsLeft == 0){
         [self.delegate largeBulletChangedToState:YES];
      }
      self.largeBulletsLeft += 5;
   }
}

@end
