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
#define RAIN_Y_OFFSET 20
@interface GameScene ()
@property (nonatomic, strong) NSMutableArray *cloudArray;
@property (nonatomic, strong) NSMutableArray *rainArray;
@end

@implementation GameScene

static const int balloonHitCategory = 1;
static const int spikeHitCategory = 2;

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      
      self.backgroundColor = [UIColor colorWithRed:.5 green:.7 blue:.3 alpha:1.0f];
      self.physicsWorld.contactDelegate = self;
              self.physicsWorld.gravity = CGVectorMake(0,-0.8);
      
      [self initializeTheElements];
      
   }
   return self;
}

- (void)initializeTheElements
{
   self.cloudArray = [[NSMutableArray alloc] init];
   SKAction *cloudWait = [SKAction waitForDuration:1.5f];
   SKAction *cloudPerformSelector = [SKAction performSelector:@selector(createCloud) onTarget:self];
   SKAction *cloudSequence = [SKAction sequence:@[cloudPerformSelector, cloudWait]];
   SKAction *cloudRepeat   = [SKAction repeatActionForever:cloudSequence];
   [self runAction:cloudRepeat];
   
   self.rainArray = [[NSMutableArray alloc] init];
   SKAction *rainWait = [SKAction waitForDuration:3.0f];
   SKAction *rainPerformSelector = [SKAction performSelector:@selector(createRain) onTarget:self];
   SKAction *rainSequence = [SKAction sequence:@[rainPerformSelector, rainWait]];
   SKAction *rainRepeat   = [SKAction repeatActionForever:rainSequence];
   [self runAction:rainRepeat];
   
}

- (void)createRain
{
   NSLog(@"rain");
   SKSpriteNode *rain = [SKSpriteNode spriteNodeWithImageNamed:@"rain"];
   rain.position = CGPointMake(rain.frame.size.width/2 + arc4random()%300, self.frame.size.height + RAIN_Y_OFFSET);
   rain.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rain.frame.size];
   rain.physicsBody.categoryBitMask = spikeHitCategory;
   rain.physicsBody.contactTestBitMask = balloonHitCategory;
   rain.physicsBody.collisionBitMask =  balloonHitCategory;
   
   [self addChild:rain];
   
   [self.rainArray addObject:rain];
   /*
   SKAction *move = [SKAction moveToY:0 duration:arc4random()%100 / 100 + 3.0];
   [rain runAction:move completion:^{
      [self.rainArray removeObject:rain];
      [rain removeFromParent];
   }];
    */
}

- (void)createCloud
{
   SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
   cloud.position = CGPointMake(-CLOUD_X_OFFSET, self.view.bounds.size.height - arc4random()%200 - STATUS_BAR_HEIGHT - cloud.frame.size.height/2);
   cloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cloud.frame.size];
   cloud.physicsBody.affectedByGravity = NO;
   cloud.physicsBody.categoryBitMask = balloonHitCategory;
   cloud.physicsBody.contactTestBitMask = spikeHitCategory;
   cloud.physicsBody.collisionBitMask =  spikeHitCategory;
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


-(void)didBeginContact:(SKPhysicsContact *)contact
{
   SKPhysicsBody *firstBody, *secondBody;
   
   firstBody = contact.bodyA;
   secondBody = contact.bodyB;
   
   if(firstBody.categoryBitMask == spikeHitCategory || secondBody.categoryBitMask == spikeHitCategory)
   {
      
      NSLog(@"balloon hit the spikes");
      //setup your methods and other things here
      
   }
}
@end
