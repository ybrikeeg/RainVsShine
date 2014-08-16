//
//  AttributorMyScene.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/15/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "GameScene.h"

#define STATUS_BAR_HEIGHT 20
#define CLOUD_X_OFFSET 50
@interface GameScene ()
@property (nonatomic, strong) NSMutableArray *cloudArray;
@end
@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
       self.backgroundColor = [UIColor colorWithRed:.5 green:.7 blue:.3 alpha:1.0f];
      [self initializeClouds];
    }
    return self;
}

- (void)initializeClouds
{
   self.cloudArray = [[NSMutableArray alloc] init];
   SKAction *wait = [SKAction waitForDuration:.1];
   SKAction *performSelector = [SKAction performSelector:@selector(createCloud) onTarget:self];
   SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
   SKAction *repeat   = [SKAction repeatActionForever:sequence];
   [self runAction:repeat];
   
}

- (void)createCloud
{
   SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
   cloud.position = CGPointMake(-CLOUD_X_OFFSET, self.view.bounds.size.height - arc4random()%200 - STATUS_BAR_HEIGHT - cloud.frame.size.height/2);
   [self addChild:cloud];

   [self.cloudArray addObject:cloud];
   
   SKAction *move = [SKAction moveToX:self.view.bounds.size.width duration:arc4random()%100 / 100 + 3.0];
   [cloud runAction:move completion:^{
      [self.cloudArray removeObject:cloud];
      [cloud removeFromParent];
   }];
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
