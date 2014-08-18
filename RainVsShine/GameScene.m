//
//  AttributorMyScene.m
//  RainVsShine
//
//  Created by Kirby Gee on 8/15/14.
//  Copyright (c) 2014 Kirby Gee - Stanford Univeristy. All rights reserved.
//

#import "GameScene.h"
#import "Rain.h"
#import "Constants.h"

#define STATUS_BAR_HEIGHT 20
#define CLOUD_X_OFFSET 50
#define RAIN_Y_OFFSET 20
@interface GameScene ()
//@property (nonatomic, strong) NSMutableArray *cloudArray;
//@property (nonatomic, strong) NSMutableArray *rainArray;
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      
      self.backgroundColor = [UIColor colorWithRed:.5 green:.7 blue:.3 alpha:1.0f];
      self.physicsWorld.contactDelegate = self;
              self.physicsWorld.gravity = CGVectorMake(0,-0.8);
      
      [self initializeTheElements];
      
      
      SKSpriteNode *roof = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.scene.size.width, 10)];
      roof.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.scene.size.width, 1)];
      
      roof.position = CGPointMake(self.scene.size.width/2, -10);
      roof.physicsBody.dynamic = NO;
      roof.physicsBody.categoryBitMask = floorCategory;
      roof.physicsBody.contactTestBitMask = rainCategory;
      roof.physicsBody.collisionBitMask = rainCategory;
      [self addChild:roof];

   }
   return self;
}

- (void)initializeTheElements
{
   //self.cloudArray = [[NSMutableArray alloc] init];
   SKAction *cloudWait = [SKAction waitForDuration:1.5f];
   SKAction *cloudPerformSelector = [SKAction performSelector:@selector(createCloud) onTarget:self];
   SKAction *cloudSequence = [SKAction sequence:@[cloudPerformSelector, cloudWait]];
   SKAction *cloudRepeat   = [SKAction repeatActionForever:cloudSequence];
   [self runAction:cloudRepeat];
   
   //self.rainArray = [[NSMutableArray alloc] init];
   SKAction *rainWait = [SKAction waitForDuration:1.0f];
   SKAction *rainPerformSelector = [SKAction performSelector:@selector(createRain) onTarget:self];
   SKAction *rainSequence = [SKAction sequence:@[rainPerformSelector, rainWait]];
   SKAction *rainRepeat   = [SKAction repeatActionForever:rainSequence];
   [self runAction:rainRepeat];
}

- (void)createRain
{
  // NSLog(@"rain: %d", [self.rainArray count]);
   Rain *rain = [[Rain alloc] initWithStyle:kRainStyleNormal];
   rain.position = CGPointMake(rain.frame.size.width/2 + arc4random()%300, self.frame.size.height + RAIN_Y_OFFSET);
   rain.physicsBody.contactTestBitMask = cloudHitCategory | floorCategory;
   rain.physicsBody.categoryBitMask = rainCategory;
   [self addChild:rain];

   //[self.rainArray addObject:rain];
}

- (void)createCloud
{
   SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
   cloud.position = CGPointMake(-CLOUD_X_OFFSET, self.view.bounds.size.height - arc4random()%200 - STATUS_BAR_HEIGHT - cloud.frame.size.height/2);
   cloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cloud.frame.size];
   cloud.physicsBody.affectedByGravity = NO;
   cloud.physicsBody.categoryBitMask = cloudHitCategory;
   cloud.physicsBody.contactTestBitMask = rainCategory;
   cloud.physicsBody.collisionBitMask =  0;
   cloud.zPosition = 2.0f;
   [self addChild:cloud];
   
   //[self.cloudArray addObject:cloud];
   
   SKAction *move = [SKAction moveToX:self.view.bounds.size.width + cloud.frame.size.width duration:arc4random()%100 / 100 + 3.0];
   [cloud runAction:move completion:^{
      //[self.cloudArray removeObject:cloud];
      [cloud removeFromParent];
   }];
}


-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
}

- (void)removeRain:(SKSpriteNode *)drop
{
   //[self.rainArray removeObject:drop];
   [drop removeFromParent];
}

- (Rain *)rainWithStyle:(RainStyle)type
{
   Rain *rain = [[Rain alloc] initWithStyle:type];
   rain.physicsBody.contactTestBitMask = floorCategory;
   rain.physicsBody.categoryBitMask = specialRainCategory;
   
   //[self.rainArray addObject:rain];
   
   return rain;
}
- (void)rain:(SKSpriteNode *)drop collideWithCloud:(SKSpriteNode *)cloud
{
   //action to move drop to center of cloud
   
   SKAction *move = [SKAction moveTo:cloud.position duration:0.1f];
   SKAction *shrink = [SKAction scaleBy:0.3f duration:0.1f];
   SKAction *group = [SKAction group:@[move, shrink]];
   SKAction *remove = [SKAction runBlock:^{
      [self removeRain:drop];
   }];

   [drop runAction:[SKAction sequence:@[group, remove]]];
   
   SKAction *wait = [SKAction waitForDuration:0.5f];
   SKAction *create = [SKAction runBlock:^{
      int specialRain = arc4random()%3;
      specialRain = 2;
      //double rain
      if (specialRain == 0){
         Rain *rain1 = [self rainWithStyle:kRainStylePair];
         rain1.position = CGPointMake(cloud.position.x - 5, cloud.position.y);
         [self addChild:rain1];
         
         Rain *rain2 = [self rainWithStyle:kRainStylePair];
         rain2.position = CGPointMake(cloud.position.x + 5, cloud.position.y);
         [self addChild:rain2];
         [rain2.physicsBody applyImpulse:CGVectorMake(0.3f, 0.0)];
         
      } else if (specialRain == 1){
         //big rain
         Rain *rain = [self rainWithStyle:kRainStyleLarge];
         rain.position = CGPointMake(cloud.position.x, cloud.position.y);
         [self addChild:rain];
      } else if (specialRain == 2){
         //evasive rain
         Rain *rain = [self rainWithStyle:kRainStyleEvasive];
         rain.position = CGPointMake(cloud.position.x, cloud.position.y);
         [self addChild:rain];
      }
   }];
   
   [self runAction:[SKAction sequence:@[wait, create]]];

}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
   SKPhysicsBody *firstBody, *secondBody;
   
   if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
      firstBody = contact.bodyA;
      secondBody = contact.bodyB;
   }
   else{
      firstBody = contact.bodyB;
      secondBody = contact.bodyA;
   }

   if ((firstBody.categoryBitMask == rainCategory || firstBody.categoryBitMask == specialRainCategory) && secondBody.categoryBitMask == floorCategory){
      //firstBody is rain
      //secondBody is floor
      //rain hit the at the bottom of the screen, remove from view and array
      [self removeRain: (SKSpriteNode *)firstBody.node];
   } else if (firstBody.categoryBitMask == rainCategory && secondBody.categoryBitMask == cloudHitCategory){
      //firstBody is rain
      //secondBody is cloud
      [self rain:(SKSpriteNode *)firstBody.node collideWithCloud:(SKSpriteNode *)secondBody.node];
   }

}
@end
