//
//  Guide.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/28/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "Guide.h"

@interface Guide ()
@property (nonatomic) NSUInteger count;
@end

@implementation Guide


- (id)init
{
   if (self = [super init]) {
      self = [Guide spriteNodeWithImageNamed:@"guide"];
   }
   
   return self;
}

@end
