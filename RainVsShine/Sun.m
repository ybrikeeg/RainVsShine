//
//  Sun.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Sun.h"
#import "GameScene.h"

@interface Sun ()
@property (nonatomic) CGPoint playerVelocity;
@property (nonatomic) CGSize screenSize;
@end

@implementation Sun

-(id)init
{
   self = [super init];
   if (self) {
      self = [Sun spriteNodeWithImageNamed:@"sun"];
      self.screenSize = [UIScreen mainScreen].bounds.size;
      self.motionManager = [[CMMotionManager alloc] init];
      [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                               withHandler:^(CMAccelerometerData *data, NSError *error){
                                                  if (!self.aiToggle){
                                                     float deceleration = 0.1f;
                                                     float sensitivity = 40.0f;
                                                     self.playerVelocity = CGPointMake(self.playerVelocity.x * deceleration + data.acceleration.x * sensitivity, 0);
                                                  }
                                               }];
      
      
      //[self runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:-M_PI duration:2.0f]]];
      [NSTimer scheduledTimerWithTimeInterval:1.0/60.0f target:self selector:@selector(update:) userInfo:nil repeats:YES];
   }
   
   return self;
}

-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
   CGPoint pos = self.position;
   pos.x += _playerVelocity.x;
   
   if (pos.x < 0){
      pos.x = 0;
      _playerVelocity = CGPointZero;
   }
   else if (pos.x > _screenSize.width){
      pos.x = _screenSize.width;
      _playerVelocity = CGPointZero;
   }
   
   
   self.position = pos;
   
}
@end
