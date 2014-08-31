//
//  Rain.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/16/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Rain.h"
#import "Constants.h"

@implementation Rain

- (id)initWithStyle:(RainStyle)type{
   if(self = [super init]) {
      if (type == kRainStyleNormal){
         _health = 1;
         self = [Rain spriteNodeWithImageNamed:@"rain"];
         self.physicsBody.categoryBitMask = rainCategory;
         self.physicsBody.contactTestBitMask = cloudHitCategory | floorCategory;
      } else if (type == kRainStylePair){
         self.health = 1;
         self = [Rain spriteNodeWithImageNamed:@"colorRain"];
         self.physicsBody.categoryBitMask = specialRainCategory;
         self.physicsBody.contactTestBitMask = floorCategory;
      } else if (type == kRainStyleLarge){
         self.health = 2;
         self = [Rain spriteNodeWithImageNamed:@"bigRain"];
         self.physicsBody.categoryBitMask = specialRainCategory;
         self.physicsBody.contactTestBitMask = floorCategory;
         self.physicsBody.mass = 3.0f;
         [self setScale:0.5f];
         SKAction *delay = [SKAction waitForDuration:0.1f];
         SKAction *scaleUp = [SKAction scaleBy:1.5f duration:0.3f];
         scaleUp.timingMode = SKActionTimingEaseInEaseOut;
         [self runAction: [SKAction sequence:@[delay, scaleUp]]];
      } else if (type == kRainStyleEvasive){
         self.health = 1;
         self = [Rain spriteNodeWithImageNamed:@"colorRain"];
         self.physicsBody.categoryBitMask = specialRainCategory;
         self.physicsBody.contactTestBitMask = floorCategory;
         SKAction *moveRight = [SKAction moveBy:CGVectorMake(30, 0) duration:0.7f];
         moveRight.timingMode = SKActionTimingEaseInEaseOut;
         SKAction *moveLeft = [SKAction moveBy:CGVectorMake(-30, 0) duration:0.7f];
         moveLeft.timingMode = SKActionTimingEaseInEaseOut;
         SKAction *repeat   = [SKAction repeatActionForever:[SKAction sequence:@[moveRight, moveLeft]]];
         [self runAction:repeat];
      }
      
      self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
      self.physicsBody.collisionBitMask = floorCategory;
      self.zPosition = 1.0f;
      self.alreadyHitCloud = NO;
   }
   return self;
}

@end