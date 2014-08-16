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

-(id) initWithStyle:(RainStyle)type{
   if(self = [super init]) {
      
      if (type == kRainStyleNormal){
         NSLog(@"Normal rain");
         self.health = 1;
         self = [Rain spriteNodeWithImageNamed:@"rain"];
         self.physicsBody.contactTestBitMask = cloudHitCategory;
         
      } else if (type == kRainStylePair){
         self.health = 1;
         self = [Rain spriteNodeWithImageNamed:@"rain"];
         
         NSLog(@"Pair rain");
      } else if (type == kRainStyleLarge){
         self.health = 2;
         self = [Rain spriteNodeWithImageNamed:@"rain"];
         
         NSLog(@"Large rain");
      } else if (type == kRainStyleEvasive){
         self.health = 1;
         self = [Rain spriteNodeWithImageNamed:@"rain"];
         NSLog(@"Evasive rain");
      }
      
      self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
      self.physicsBody.categoryBitMask = rainCategory;
      self.physicsBody.contactTestBitMask |= floorCategory;
      self.physicsBody.collisionBitMask = floorCategory;
      self.zPosition = 1.0f;
   }
   return self;
}

@end
