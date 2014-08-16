//
//  Rain.h
//  RainVsShine
//
//  Created by Kirby Gee on 8/16/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
   kRainStyleNormal,
   kRainStylePair,
   kRainStyleLarge,
   kRainStyleEvasive
} RainStyle;

@interface Rain : SKSpriteNode

@property (nonatomic) int health;

-(id) initWithStyle:(RainStyle)type;

@end
