//
//  Cloud.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/17/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Cloud.h"

@interface Cloud ()

@property (nonatomic, strong) NSArray *walkFrames;

@end

@implementation Cloud

-(id)init
{
   self = [super init];
   if(self) {
      self = [Cloud spriteNodeWithImageNamed:@"cloud"];
      self.isAnimating = NO;
      
      SKTexture *cloud = [SKTexture textureWithImageNamed:@"cloud"];
      SKTexture *lightning = [SKTexture textureWithImageNamed:@"cloudLightning"];

      self.walkFrames = @[lightning, lightning, cloud, cloud, cloud, lightning, lightning, cloud, cloud, lightning, lightning, cloud ,cloud, cloud, cloud, cloud ,cloud, cloud, cloud,cloud ,cloud, cloud, cloud,cloud ,cloud, cloud, cloud,cloud ,cloud, cloud, cloud,cloud ,cloud, lightning, lightning, cloud];//39 freames
      
   }
   
   return self;
}


- (void)startAnimating
{
   self.isAnimating = YES;
   [self runAction:[SKAction animateWithTextures:_walkFrames timePerFrame:0.8/(float)[_walkFrames count] resize:YES restore:YES]];
   
}
@end
