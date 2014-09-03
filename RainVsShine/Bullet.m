//
//  Bullet.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
- (id)initWithBulletType:(BulletType)type
{
   self = [super init];
   if (self) {
      self = [Bullet spriteNodeWithImageNamed:@"bullet"];
      self.damage = (type == kBulletNormal) ? 1 : 2;
      self.alreadyHitCloud = NO;
      
      NSString *resource = (type == kBulletNormal) ? @"bulletCloudCollisionForTypeNormal" : @"bulletCloudCollisionForTypeLarge";
      
      NSString *burstPath = [[NSBundle mainBundle] pathForResource:resource ofType:@"sks"];
      SKEmitterNode *burstEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
      burstEmitter.position = CGPointMake(self.position.x, self.position.y - 14);
      burstEmitter.zPosition = -1;
      [self addChild:burstEmitter];
      
      self.zPosition = 1;
   }
   
   return self;
}
@end
