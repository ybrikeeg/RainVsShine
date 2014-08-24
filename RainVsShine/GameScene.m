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
#import "Sun.h"
#import "Bullet.h"
#import "Cloud.h"

#define STATUS_BAR_HEIGHT 20
#define CLOUD_X_OFFSET 50
#define RAIN_Y_OFFSET 40

@interface GameScene ()
@property (nonatomic, strong)Sun *sunPlayer;
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
      
      
      SKSpriteNode *ceiling = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.scene.size.width, 10)];
      ceiling.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.scene.size.width, 1)];
      ceiling.position = CGPointMake(self.scene.size.width/2, self.scene.size.height + 50);
      ceiling.physicsBody.dynamic = NO;
      ceiling.physicsBody.categoryBitMask = ceilingCategory;
      ceiling.physicsBody.contactTestBitMask = bulletCategory;
      ceiling.physicsBody.collisionBitMask = bulletCategory;
      [self addChild:ceiling];
      
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
   
   
   self.sunPlayer = [[Sun alloc] init];
   self.sunPlayer.position = CGPointMake(self.frame.size.width/2, 0);
   [self addChild:self.sunPlayer];
}

- (void)createRain
{
   Rain *rain = [self rainWithStyle:kRainStyleNormal];
   rain.position = CGPointMake(rain.frame.size.width/2 + arc4random()%300, self.frame.size.height + RAIN_Y_OFFSET);
   [self addChild:rain];
}

- (void)createCloud
{
   Cloud *cloud = [[Cloud alloc] init];
   cloud.position = CGPointMake(-CLOUD_X_OFFSET, self.view.bounds.size.height - arc4random()%200 - STATUS_BAR_HEIGHT - cloud.frame.size.height/2);
   cloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cloud.frame.size];
   cloud.physicsBody.affectedByGravity = NO;
   cloud.physicsBody.categoryBitMask = cloudHitCategory;
   cloud.physicsBody.contactTestBitMask = rainCategory | bulletCategory;
   cloud.physicsBody.collisionBitMask =  0;
   cloud.zPosition = 2.0f;
   [self addChild:cloud];
   
   SKAction *move = [SKAction moveToX:self.view.bounds.size.width + cloud.frame.size.width duration:arc4random()%100 / 100 + 3.0];
   [cloud runAction:move completion:^{
      [cloud removeFromParent];
   }];
}


-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
}

- (void)removeRain:(Rain *)drop
{
   [drop removeFromParent];
}

- (Rain *)rainWithStyle:(RainStyle)type
{
   Rain *rain = [[Rain alloc] initWithStyle:type];
   if (type == kRainStyleNormal){
      rain.physicsBody.categoryBitMask = rainCategory;
      rain.physicsBody.contactTestBitMask = floorCategory | cloudHitCategory | bulletCategory;
      
   } else{
      rain.physicsBody.categoryBitMask = specialRainCategory;
      rain.physicsBody.contactTestBitMask = floorCategory | bulletCategory;
   }
   
   if (type == kRainStyleLarge){
      rain.health = 2;
   } else{
      rain.health = 1;
   }
   
   return rain;
}

- (void)rain:(Rain *)drop collideWithCloud:(Cloud *)cloud
{
   //action to move drop to center of cloud
   cloud.physicsBody.contactTestBitMask = bulletCategory;
   //cloud.physicsBody.categoryBitMask = 0;
   
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
      
      if (specialRain == 0){
         //double rain
         Rain *rain1 = [self rainWithStyle:kRainStylePair];
         rain1.position = CGPointMake(cloud.position.x - 10, cloud.position.y);
         [self addChild:rain1];
         [rain1.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
         
         Rain *rain2 = [self rainWithStyle:kRainStylePair];
         rain2.position = CGPointMake(cloud.position.x + 10, cloud.position.y);
         [self addChild:rain2];
         [rain2.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
      } else if (specialRain == 1){
         //large rain
         Rain *rain = [self rainWithStyle:kRainStyleLarge];
         rain.position = CGPointMake(cloud.position.x, cloud.position.y);
         [self addChild:rain];
         [rain.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
      } else if (specialRain == 2){
         //evasive rain
         Rain *rain = [self rainWithStyle:kRainStyleEvasive];
         rain.position = CGPointMake(cloud.position.x, cloud.position.y);
         [self addChild:rain];
         [rain.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
      }
      
   }];
   
   [self runAction:[SKAction sequence:@[wait, create]] completion:^{
      cloud.physicsBody.contactTestBitMask = rainCategory;
      cloud.physicsBody.categoryBitMask = cloudHitCategory;
      
   }];
   
}

- (void)removeBullet:(Bullet *)bullet
{
   [bullet removeFromParent];
}

- (void)rain:(Rain *)rain collideWithBullet:(Bullet *)bullet
{
   NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"rainBulletCollision" ofType:@"sks"];
   SKEmitterNode *burstEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
   burstEmitter.position = bullet.position;
   [self addChild:burstEmitter];
   
   rain.health -= bullet.damage;
   if (rain.health <= 0){
      [self removeRain:rain];
   } else{
      [rain runAction:[SKAction scaleBy:0.5f duration:0.2f]];
   }
   
   [self removeBullet:bullet];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   /*
   Bullet *bullet = [[Bullet alloc] init];
   bullet.position = self.sunPlayer.position;
   bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.frame.size];
   
   bullet.physicsBody.categoryBitMask = bulletCategory;
   bullet.physicsBody.contactTestBitMask = cloudHitCategory | rainCategory | specialRainCategory | ceilingCategory;
   bullet.physicsBody.collisionBitMask = 0;
   [self addChild:bullet];
   
   [bullet.physicsBody applyImpulse:CGVectorMake(0.0, 30.0)];
   */
   [self createBulletWithImpulse:CGVectorMake(0.0f, 30.0f) position:self.sunPlayer.position categoryBitMask:bulletCategory alreadyHitCloud:NO];
}

- (void)createBulletWithImpulse:(CGVector)impulse position:(CGPoint)pos categoryBitMask:(uint32_t)mask alreadyHitCloud:(BOOL)alreadyHitCloud
{
   Bullet *bullet = [[Bullet alloc] init];
   bullet.position = pos;
   
   bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.frame.size];
   
   bullet.physicsBody.categoryBitMask = specialBulletCategory;
   bullet.physicsBody.contactTestBitMask = cloudHitCategory | rainCategory | specialRainCategory | ceilingCategory;
   bullet.physicsBody.collisionBitMask = 0;
   bullet.alreadyHitCloud = alreadyHitCloud;
   [self addChild:bullet];
   
   if (alreadyHitCloud){
      [bullet runAction:[SKAction rotateByAngle:tan(impulse.dy/impulse.dx) duration:0.01f]];
   }
   [bullet.physicsBody applyImpulse:impulse];
}

- (void)bullet:(Bullet *)bullet collideWithCloud:(Cloud *)cloud
{
   if (!bullet.alreadyHitCloud){
      bullet.alreadyHitCloud = YES;
      [self createBulletWithImpulse:CGVectorMake(-10.0f, 30.0f) position:bullet.position categoryBitMask:specialBulletCategory alreadyHitCloud:YES];
      [self createBulletWithImpulse:CGVectorMake(10.0f, 30.0f) position:bullet.position categoryBitMask:specialBulletCategory alreadyHitCloud:YES];
   }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
   SKPhysicsBody *firstBody, *secondBody;
   if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
      firstBody = contact.bodyA;
      secondBody = contact.bodyB;
   } else{
      firstBody = contact.bodyB;
      secondBody = contact.bodyA;
   }
   
   if ((firstBody.categoryBitMask == rainCategory || firstBody.categoryBitMask == specialRainCategory) && secondBody.categoryBitMask == floorCategory){
      //rain hit the at the bottom of the screen, remove from view and array
      [self removeRain: (Rain *)firstBody.node];
   } else if (firstBody.categoryBitMask == rainCategory && secondBody.categoryBitMask == cloudHitCategory){
      [self rain:(Rain *)firstBody.node collideWithCloud:(Cloud *)secondBody.node];
   } else if ((firstBody.categoryBitMask == rainCategory || firstBody.categoryBitMask == specialRainCategory) && (secondBody.categoryBitMask == bulletCategory || secondBody.categoryBitMask == specialBulletCategory)){
      NSLog(@"booom!");
      [self rain:(Rain *)firstBody.node collideWithBullet:(Bullet *)secondBody.node];
   }else if (firstBody.categoryBitMask == ceilingCategory && (secondBody.categoryBitMask == bulletCategory || secondBody.categoryBitMask == specialBulletCategory)){
      NSLog(@"ceiling!");
      [self removeBullet:(Bullet *)secondBody.node];
   }
   else if (firstBody.categoryBitMask == cloudHitCategory && secondBody.categoryBitMask == bulletCategory){
      NSLog(@"bullet cloud!");
      [self bullet:(Bullet *)secondBody.node collideWithCloud:(Cloud *)firstBody.node];
      //[self removeBullet:(Bullet *)secondBody.node];
   }   else if (firstBody.categoryBitMask == cloudHitCategory && secondBody.categoryBitMask == specialBulletCategory){
      NSLog(@"bullet cloud!");
      [self bullet:(Bullet *)secondBody.node collideWithCloud:(Cloud *)firstBody.node];
      //[self removeBullet:(Bullet *)secondBody.node];
   }
}
@end