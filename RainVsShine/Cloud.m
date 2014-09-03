//
//  Cloud.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/17/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Cloud.h"

@implementation Cloud

-(id)init
{
   self = [super init];
   if(self) {
      self = [Cloud spriteNodeWithImageNamed:@"cloud"];
   
   }
   
   return self;
}

@end
