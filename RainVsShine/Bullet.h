//
//  Bullet.h
//  RainVsShine
//
//  Created by Kirby Gee on 8/23/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


typedef enum {
   kBulletNormal,
   kBulletLarge
} BulletType;

@interface Bullet : SKSpriteNode

@property (nonatomic)NSInteger damage;
@property (nonatomic) BOOL alreadyHitCloud;
@property (nonatomic) NSUInteger identifier;


- (id)initWithBulletType:(BulletType)type;

@end
