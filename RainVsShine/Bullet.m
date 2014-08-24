//
//  Bullet.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
-(id)init
{
   if(self = [super init]) {
      self = [Bullet spriteNodeWithImageNamed:@"bullet"];
      self.damage = 1;
      self.alreadyHitCloud = NO;
   }
   
   return self;
}
@end
