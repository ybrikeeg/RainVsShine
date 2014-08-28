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

#define USE_AUTO_FIRE 0


#define STATUS_BAR_HEIGHT 20
#define CLOUD_X_OFFSET 50
#define RAIN_Y_OFFSET 40

@interface GameScene ()
@property (nonatomic, strong) Sun *sunPlayer;
@property (nonatomic, strong) NSMutableArray *rainArray;
@property (nonatomic) NSInteger aiToggle;
@property (nonatomic) NSUInteger streak;
@property (nonatomic) NSUInteger consecutive;
@property (nonatomic) NSUInteger lastIdentifier;
@property (nonatomic) NSUInteger bulletCount;
@property (nonatomic, strong) UILabel *streakLabel;
@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size]) {
      
      self.backgroundColor = [UIColor colorWithRed:.5 green:.7 blue:.3 alpha:1.0f];
      self.physicsWorld.contactDelegate = self;
      self.physicsWorld.gravity = CGVectorMake(0,-0.8);
      self.physicsWorld.speed = 1.0f;
      
      self.streak = 0;
      self.consecutive = 0;
      self.bulletCount = 0;
      [self createHUD];
      [self initializeTheElements];
      [self createBoundaries];
      
      self.aiToggle = USE_AUTO_FIRE;
      self.rainArray = [[NSMutableArray alloc] init];
      
   }
   return self;
}

- (void) didMoveToView:(SKView *)view
{
   UISwitch *ai = [[UISwitch alloc] init];
   ai.center = CGPointMake(self.view.frame.size.width/2, ai.frame.size.height/2);
   [ai addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
   [ai setOn:self.aiToggle];
   [self.view addSubview:ai];
   
   self.streakLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, ai.frame.size.height/2, 40, 20)];
   [self.view addSubview:self.streakLabel];
}




- (void)toggle:(UISwitch *)theSwitch
{
   if (self.aiToggle == 1){
      self.aiToggle = 0;
   } else if (self.aiToggle == 0){
      self.aiToggle = 1;
   }
   
   self.sunPlayer.aiToggle = self.aiToggle;

}

- (void)setStreak:(NSUInteger)streak
{
   _streak = streak;
   self.streakLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.streak];
   NSLog(@"streak: %lu", (unsigned long)_streak);
}
- (void)createHUD
{
   SKSpriteNode *hudSprite = [SKSpriteNode spriteNodeWithImageNamed:@"hud"];
   hudSprite.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - hudSprite.frame.size.height/2);
   hudSprite.zPosition = 100;
   [self addChild:hudSprite];
   
   //add life indicators
   for (int i = 0; i < 3; i ++){
      SKSpriteNode *lifeSun = [SKSpriteNode spriteNodeWithImageNamed:@"sunLife"];
      lifeSun.position = CGPointMake(self.frame.size.width - 20 - (lifeSun.frame.size.width * i), self.frame.size.height - 20);
      lifeSun.zPosition = 101;
      [self addChild:lifeSun];
      
      SKAction *scaleDown = [SKAction scaleTo:0.9f duration:1.0f];
      SKAction *scaleUp = [SKAction scaleTo:1.1f duration:1.0f];
      SKAction *sequence = [SKAction sequence:@[scaleUp, scaleDown]];
      SKAction *rotate = [SKAction rotateByAngle:M_PI duration:2.0f];

      SKAction *repeat   = [SKAction repeatActionForever:[SKAction group:@[rotate, sequence]]];
      [lifeSun runAction:repeat];
      
   }
   
   //add play/pause button
   SKSpriteNode *playPause = [SKSpriteNode spriteNodeWithImageNamed:@"pauseButton"];
   playPause.position = CGPointMake(20, self.frame.size.height - hudSprite.frame.size.height/2);
   playPause.zPosition = 101;
   playPause.name = @"pauseButton";
   [self addChild:playPause];
   
}


/*
 *    Creates the roof and ceiling to remove bulelts/rains
 */
- (void)createBoundaries
{
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

#pragma mark - Create rain and cloud schedulers
/*
 *    Creates the scheduler for the rain and cloud creators, and
 *    adds sun to the screen
 */
- (void)initializeTheElements
{
   SKAction *cloudWait = [SKAction waitForDuration:1.5f];
   SKAction *cloudPerformSelector = [SKAction performSelector:@selector(createCloud) onTarget:self];
   SKAction *cloudSequence = [SKAction sequence:@[cloudPerformSelector, cloudWait]];
   SKAction *cloudRepeat   = [SKAction repeatActionForever:cloudSequence];
   [self runAction:cloudRepeat];
   
   SKAction *rainWait = [SKAction waitForDuration:(self.aiToggle) ? 0.07f : 1.0f];
   SKAction *rainPerformSelector = [SKAction performSelector:@selector(createRain) onTarget:self];
   SKAction *rainSequence = [SKAction sequence:@[rainPerformSelector, rainWait]];
   SKAction *rainRepeat   = [SKAction repeatActionForever:rainSequence];
   [self runAction:rainRepeat];
   
   if (!self.sunPlayer){
   self.sunPlayer = [[Sun alloc] init];
   self.sunPlayer.position = CGPointMake(self.frame.size.width/2, 0);
   [self addChild:self.sunPlayer];
   }
}

/*
 *    Creates clouds on a given scheduler and lets gravity pull them
 *    to the bottom of the screen
 */
- (void)createRain
{
   Rain *rain = [self rainWithStyle:kRainStyleNormal];
   rain.position = CGPointMake(rain.frame.size.width/2 + arc4random()%300, self.frame.size.height + RAIN_Y_OFFSET);
   [self addChild:rain];
   if (self.aiToggle){
      [self.rainArray addObject:rain];
   }
}

/*
 *    Creates clouds on a given scheduler and moves them across the screen
 */
- (void)createCloud
{
   Cloud *cloud = [[Cloud alloc] init];
   cloud.position = CGPointMake(-CLOUD_X_OFFSET, self.view.bounds.size.height - arc4random()%200 - STATUS_BAR_HEIGHT - 50 - cloud.frame.size.height/2);
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

/*
 *    Creates rain with the parameterized type and applies the
 *    correct bit masks and health
 */
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

/*
 *    Remove rain drop scene
 */
- (void)removeRain:(Rain *)drop
{
   [drop removeFromParent];
}

/*
 *    Remove bullet scene
 */
- (void)removeBullet:(Bullet *)bullet
{
   [bullet removeFromParent];
}

#pragma  mark - Auto-fire
/*
 *    Called every frame. If auto fire is on, then the sun will
 *    move to the appropriate position and fire on the rain
 */
-(void)update:(CFTimeInterval)currentTime {
   /* Called before each frame is rendered */
   
   if (self.aiToggle){
      if ([self.rainArray count] > 0 && !self.sunPlayer.hasActions){
         
         int x = 0;
         Rain *rain = [self.rainArray objectAtIndex:x];
         while (rain.position.y < 0) {
            [self.rainArray removeObject:rain];
            rain = [self.rainArray objectAtIndex:x];
            x++;
         }
         for (int i = 1; i < [self.rainArray count]; i++){
            Rain *currRain = [self.rainArray objectAtIndex:i];
            if (currRain.position.y < 0){
               [self.rainArray removeObject:currRain];
            }
            if (rain.position.y > currRain.position.y){
               rain = currRain;
            }
         }
         
         if (rain.health < 2){
            [self.rainArray removeObject:rain];
         }
         
         SKAction *scaleUp = [SKAction scaleTo:0.8f duration:0.1f];
         SKAction *scaledown = [SKAction scaleTo:1.2f duration:0.1f];
         SKAction *sequence = [SKAction sequence:@[scaleUp, scaledown]];
         SKAction *repeat   = [SKAction repeatActionForever:sequence];
         [rain runAction:repeat];
         
         CGFloat duration =  (self.aiToggle) ? 0.05f : arc4random()%80 / (float)50;
         [self.sunPlayer runAction:[SKAction sequence:@[[SKAction moveToX:rain.position.x duration:0.06f], [SKAction waitForDuration:duration]]] completion:^{
            [self createBulletWithImpulse:CGVectorMake(0.0f, 30.0f) position:self.sunPlayer.position categoryBitMask:bulletCategory alreadyHitCloud:NO identifier:self.bulletCount++];
            
         }];
      }
   }
}

#pragma mark - Create bullets

/*
 *    Fire a bullet at the sun's current position when the user touches the screen
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   UITouch *touch = [touches anyObject];
   CGPoint location = [touch locationInNode:self];
   SKNode *node = [self nodeAtPoint:location];
   
   if ([node.name isEqualToString:@"pauseButton"]) {
      SKSpriteNode *button = (SKSpriteNode *)node;
      button.name = @"playButton";
      button.texture = [SKTexture textureWithImageNamed:@"pauseButton"];
      SKAction *wait = [SKAction runBlock:^{
         self.scene.view.paused = YES;
      }];
      [button runAction:wait];
      NSLog(@"texture1: %@", button.texture);
   } else if ([node.name isEqualToString:@"playButton"]) {
      SKSpriteNode *button = (SKSpriteNode *)node;
      button.name = @"pauseButton";
      button.texture = [SKTexture textureWithImageNamed:@"playButton"];
      SKAction *wait = [SKAction runBlock:^{
         self.scene.view.paused = NO;
      }];
      [button runAction:wait];
      NSLog(@"texture2: %@", button.texture);
   } else{
      [self createBulletWithImpulse:CGVectorMake(0.0f, 30.0f) position:self.sunPlayer.position categoryBitMask:bulletCategory alreadyHitCloud:NO identifier:self.bulletCount++];
   }
}

/*
 *    This method creates the bullet, applies the appropriate
 *    impulse (could have non-zero dx if hit cloud), correct position
 *    sun's position or bullet's position (if hit cloud), correct mask,
 *    and bool if it has already hit a cloud
 */
- (void)createBulletWithImpulse:(CGVector)impulse position:(CGPoint)pos categoryBitMask:(uint32_t)mask alreadyHitCloud:(BOOL)alreadyHitCloud identifier:(NSUInteger)identifier
{
   Bullet *bullet = [[Bullet alloc] init];
   bullet.position = pos;
   
   bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.frame.size];
   bullet.physicsBody.categoryBitMask = mask;
   bullet.physicsBody.contactTestBitMask = cloudHitCategory | rainCategory | specialRainCategory | ceilingCategory;
   bullet.physicsBody.collisionBitMask = 0;
   bullet.physicsBody.usesPreciseCollisionDetection = YES;
   bullet.alreadyHitCloud = alreadyHitCloud;
   bullet.identifier = identifier;
   [self addChild:bullet];
   
   if (alreadyHitCloud){
      [bullet runAction:[SKAction rotateByAngle:tan(impulse.dy/impulse.dx) duration:0.01f]];
   }
   [bullet.physicsBody applyImpulse:impulse];
}

#pragma mark - Collision code

/*
 *    Method creates special rain when rain hits cloud and changes
 *    the appropriate bit masks
 */
- (void)rain:(Rain *)drop collideWithCloud:(Cloud *)cloud
{
   if (!drop.alreadyHitCloud){
      drop.alreadyHitCloud = YES;
      if (cloud.position.x < 200){
         if (self.aiToggle){
            if ([_rainArray containsObject:drop]){
               [self.rainArray removeObject:drop];
            }
         }
         //action to move drop to center of cloud
         cloud.physicsBody.contactTestBitMask = bulletCategory;
         
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
               
               if (self.aiToggle){
                  [self.rainArray insertObject:rain1 atIndex:0];
                  [self.rainArray insertObject:rain2 atIndex:0];
               }
            } else if (specialRain == 1){
               //large rain
               Rain *rain = [self rainWithStyle:kRainStyleLarge];
               rain.position = CGPointMake(cloud.position.x, cloud.position.y);
               [self addChild:rain];
               [rain.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
               
               if (self.aiToggle){
                  [self.rainArray insertObject:rain atIndex:0];
               }
            } else if (specialRain == 2){
               //evasive rain
               Rain *rain = [self rainWithStyle:kRainStyleEvasive];
               rain.position = CGPointMake(cloud.position.x, cloud.position.y);
               [self addChild:rain];
               [rain.physicsBody applyImpulse:CGVectorMake(0.0, -1.0)];
               
               if (self.aiToggle){
                  [self.rainArray insertObject:rain atIndex:0];
               }
            }
            
         }];
         
         [self runAction:[SKAction sequence:@[wait, create]] completion:^{
            cloud.physicsBody.contactTestBitMask = rainCategory;
            cloud.physicsBody.categoryBitMask = cloudHitCategory;
            
         }];
      }
   } else if (drop.alreadyHitCloud){
      //do nothing. with out alreadyHitCloud, this would cause multiple special
      //rains to be initialized
   }
}

/*
 *    Added particle emitter to scene and remove bullet if health
 *    is zero
 */
- (void)rain:(Rain *)rain collideWithBullet:(Bullet *)bullet
{
   NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"rainBulletCollision" ofType:@"sks"];
   SKEmitterNode *burstEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
   burstEmitter.position = bullet.position;
   [self addChild:burstEmitter];
   
   rain.health -= bullet.damage;
   if (rain.health <= 0){
      self.streak++;
      [self removeRain:rain];
      if (self.aiToggle){
         if ([_rainArray containsObject:rain]){
            [self.rainArray removeObject:rain];
         }
      }
   } else{
      [rain runAction:[SKAction scaleBy:0.5f duration:0.2f]];
   }
   [self removeBullet:bullet];
}

/*
 *    Creates the bullet burst effect where it spawns 2 more bullets
 *    and changes alreadyHitCloud bool
 */
- (void)bullet:(Bullet *)bullet collideWithCloud:(Cloud *)cloud
{
   if (!bullet.alreadyHitCloud){
      bullet.alreadyHitCloud = YES;
      [self createBulletWithImpulse:CGVectorMake(-10.0f, 30.0f) position:CGPointMake(bullet.position.x, bullet.position.y + 10) categoryBitMask:specialBulletCategory alreadyHitCloud:YES identifier:bullet.identifier];
      [self createBulletWithImpulse:CGVectorMake(10.0f, 30.0f) position:CGPointMake(bullet.position.x, bullet.position.y + 10) categoryBitMask:specialBulletCategory alreadyHitCloud:YES identifier:bullet.identifier];
   }
}

/*
 *    When the bullet hits the ceiling, check category bit mask
 *    to determine if streak should be reset
 */
- (void)bullet:(Bullet *)bullet collideWithCeiling:(SKNode *)ceiling
{
   
   if (self.lastIdentifier == bullet.identifier){
      self.consecutive++;
   } else{
      self.consecutive = 0;
      if (bullet.physicsBody.categoryBitMask == bulletCategory){
         self.streak = 0;
      }
   }
   
   if (self.consecutive == 2){
      self.streak = 0;
   }
   self.lastIdentifier = bullet.identifier;
   
   [self removeBullet:bullet];
}

/*
 *    Delegate method for any collisions. Handles all the logic
 *    for any type of collision. Category bit mask order is important
 *    for assigning firstBody/secondBody nodes
 */
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
   
   if (firstBody.categoryBitMask == cloudHitCategory && (secondBody.categoryBitMask == bulletCategory || secondBody.categoryBitMask == specialBulletCategory)){
      [self bullet:(Bullet *)secondBody.node collideWithCloud:(Cloud *)firstBody.node];
   }else if ((firstBody.categoryBitMask == rainCategory || firstBody.categoryBitMask == specialRainCategory) && secondBody.categoryBitMask == floorCategory){
      [self removeRain: (Rain *)firstBody.node];
      if (self.aiToggle){
         if ([_rainArray containsObject:(Rain *)firstBody.node]){
            [self.rainArray removeObject:(Rain *)firstBody.node];
         }
      }
      
   }else if (firstBody.categoryBitMask == rainCategory && secondBody.categoryBitMask == cloudHitCategory){
      [self rain:(Rain *)firstBody.node collideWithCloud:(Cloud *)secondBody.node];
      
   }else if ((firstBody.categoryBitMask == rainCategory || firstBody.categoryBitMask == specialRainCategory) && (secondBody.categoryBitMask == bulletCategory || secondBody.categoryBitMask == specialBulletCategory)){
      [self rain:(Rain *)firstBody.node collideWithBullet:(Bullet *)secondBody.node];
      
   }else if (firstBody.categoryBitMask == ceilingCategory && (secondBody.categoryBitMask == bulletCategory || secondBody.categoryBitMask == specialBulletCategory)){
      [self bullet:(Bullet *)secondBody.node collideWithCeiling:firstBody.node];
      [self removeBullet:(Bullet *)secondBody.node];
      
   }
}

@end