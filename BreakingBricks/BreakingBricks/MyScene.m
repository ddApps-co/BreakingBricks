//
//  MyScene.m
//  BreakingBricks
//
//  Created by Dulio Denis on 8/31/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "MyScene.h"
#import "EndScene.h"
#import "HUDNode.h"

static const int BrickPoint = 1;        // Every Brick is a Point
static const int BrickPointRed = 4;     // Every Red Brick is 4 Points
static const int GreyBall = 0;          // The Normal Ball
static const int RedBall = 1;           // The Red Ball
static const int BrickTier1 = 4;        // Number of Bricks in Level
static const int BrickTier2 = 8;
static const int BrickTier3 = 12;
// Brick Types
static const int GreyBrick = 0;
static const int RedBrick = 1;
static const int BlueBrick = 2;
static const int YellowBrick = 3;
// Game Play
static const int AdvancedGamePlay = 10; // Advanced Game Play Triggered


@interface MyScene()
@property (nonatomic) SKSpriteNode *paddle;
@property (nonatomic) SKAction *paddleSound;
@property (nonatomic) SKAction *brickSound;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger bricks;
@property (nonatomic) BOOL redBallInPlay; // Keeps track when the Red Ball is in Play
@property (nonatomic) BOOL bottomEdgeOn;  // Removes the bottome edge (Yellow Power On)
@end


#pragma mark - Categories
static const uint32_t ballCategory        = 0x1 << 0;
//static const uint32_t redBallCategory     = 0x1 << 1;
static const uint32_t greyBrickCategory   = 0x1 << 2;
static const uint32_t redBrickCategory    = 0x1 << 3;
static const uint32_t blueBrickCategory   = 0x1 << 4;
static const uint32_t yellowBrickCategory = 0x1 << 5;
static const uint32_t paddleCategory      = 0x1 << 6;
static const uint32_t edgeCategory        = 0x1 << 7;
static const uint32_t bottomEdgeCategory  = 0x1 << 8;


@implementation MyScene

#pragma mark - Add the Ball, Add Impulse to the Ball

- (void)addBall:(CGSize)size atPosition:(CGPoint)ballPosition ofType:(int)ballType {
    // create a new sprite node from an image
    SKSpriteNode *ball = [SKSpriteNode node];
    if (ballType == GreyBall) {
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        ball.name = @"ball";
        // create a CGPoint for position
        CGPoint point = CGPointMake(size.width/2, size.height/2);
        ball.position = point;
        
        // add a physics body
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        ball.physicsBody.friction = 0;
        ball.physicsBody.linearDamping = 0;
        ball.physicsBody.restitution = 1;
        
        // add the category
        ball.physicsBody.categoryBitMask = ballCategory;
        
        // add the contact category notification with bricks and paddle
        ball.physicsBody.contactTestBitMask = redBrickCategory | blueBrickCategory | yellowBrickCategory | greyBrickCategory | paddleCategory | bottomEdgeCategory;
        
        // add the collision bitmask of the edge and the brick - ball passes right thru paddle
        // ball.physicsBody.collisionBitMask = edgeCategory | brickCategory;
    } else {
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"redball"];
        ball.name = @"redball";
        ball.position = ballPosition;
        
        // add a physics body
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        ball.physicsBody.friction = 0;
        ball.physicsBody.linearDamping = 0;
        ball.physicsBody.restitution = 1;
        
        // add the category
        ball.physicsBody.categoryBitMask = ballCategory;
        
        // add the contact category notification with bricks and paddle
        ball.physicsBody.contactTestBitMask = redBrickCategory | blueBrickCategory | yellowBrickCategory | greyBrickCategory | paddleCategory | bottomEdgeCategory;
        
        self.redBallInPlay = YES;
    }
    // add the sprite node to the scene
    [self addChild:ball];
    // and give it a nudge
    [self addImpulse];
}


- (void)addImpulse {
    // create a vector
    CGVector vector = CGVectorMake(10, 10);
    //apply the vector
    SKSpriteNode *ball = (SKSpriteNode*)[self childNodeWithName:@"ball"];
    [ball.physicsBody applyImpulse:vector];
    
    if (self.redBallInPlay) {
        SKSpriteNode *redball = (SKSpriteNode*)[self childNodeWithName:@"redball"];
        [redball.physicsBody applyImpulse:vector];
    }
}


#pragma mark - Add the Player

- (void)addPlayer:(CGSize)size {
    // create paddle sprite
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle"];
    self.paddle.position = CGPointMake(size.width/2, 100);
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    
    // make it static
    self.paddle.physicsBody.dynamic = NO;
    
    // add category
    self.paddle.physicsBody.categoryBitMask = paddleCategory;
    
    // add to scene
    [self addChild:self.paddle];
}


#pragma mark - Control the player

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint newPosition = CGPointMake(location.x, 100);
        
        // stop the paddle from going to far
        if (newPosition.x < self.paddle.size.width/2) {
            newPosition.x = self.paddle.size.width/2;
        }
        if (newPosition.x > self.size.width - (self.paddle.size.width/2)) {
            newPosition.x = self.size.width - (self.paddle.size.width/2);
        }
        
        self.paddle.position = newPosition;
    }
}


#pragma mark - Add Bricks

- (void)addBricks:(CGSize)size atLevel:(NSInteger)brickTier {
    for (int i = 0; i < 4; i++) {
        SKSpriteNode *brick = [SKSpriteNode node];
        // NSLog(@"Level = %d", self.level);
        if ([self checkPoints] >= AdvancedGamePlay) {
            NSArray *brickArray = @[@"brick", @"redbrick", @"bluebrick", @"yellowbrick"];
            uint32_t brickCategoryArray[4] = {greyBrickCategory, redBrickCategory, blueBrickCategory, yellowBrickCategory};
            NSUInteger brickTypeNumber = arc4random_uniform(4);
            
            NSString *brickType = brickArray[brickTypeNumber];
            brick = [SKSpriteNode spriteNodeWithImageNamed:brickType];
            
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = brickCategoryArray[brickTypeNumber];
            
        } else {
            brick = [SKSpriteNode spriteNodeWithImageNamed:@"brick"];
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = greyBrickCategory;
        }
    
        int xPosition = size.width/5 * (i+1);
        int yPosition = size.height - 50;
        brick.position = CGPointMake(xPosition, yPosition);
        
        [self addChild:brick];
    }
    
    // if brickTier == 2 draw a second row
    if (brickTier == BrickTier2) {
        for (int i = 0; i < 4; i++) {
            SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:@"brick"];
            
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = greyBrickCategory;
            
            int xPosition = size.width/5 * (i+1);
            int yPosition = size.height - 100;
            brick.position = CGPointMake(xPosition, yPosition);
            
            [self addChild:brick];
        }
    }
    // if brickTier == 3 draw a third row
    if (brickTier == BrickTier3) {
        for (int i = 0; i < 4; i++) {
            SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:@"brick"];
            
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = greyBrickCategory;
            
            int xPosition = size.width/5 * (i+1);
            int yPosition = size.height - 150;
            brick.position = CGPointMake(xPosition, yPosition);
            
            [self addChild:brick];
        }
    }
}


#pragma mark - Add and Remove the Bottom Edge

- (void)addBottomEdge:(CGSize)size {
    if (self.bottomEdgeOn) {
        SKNode *bottomEdge = [SKNode node];
        bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1)
                                                              toPoint:CGPointMake(size.width, 1)];
        bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory;
        bottomEdge.name = @"bottomEdge";
        [self addChild:bottomEdge];
    }
}


- (void)removeBottomEdge:(CGSize)size {
    if (self.bottomEdgeOn) {
        SKNode *bottomEdge = [self childNodeWithName: @"bottomEdge"];
        [bottomEdge removeFromParent];
    }
}


#pragma mark - Initialize the Scene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        
        // add a physics body to the scene
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = edgeCategory;
        
        // change the gravity settings of the physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        // there bottom edge is on
        self.bottomEdgeOn = YES; // NO for testing
        
        // add the objects to the scene
        [self addBall:size atPosition:CGPointZero ofType:GreyBall];
        [self addPlayer:size];
        [self addBricks:size atLevel:BrickTier1];
        [self addBottomEdge:size];
        
        // preload sound effects
        self.paddleSound = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
        self.brickSound = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
        
        // initialize level and bricks: Level 1 = 4 Bricks
        self.level = 1;
        self.bricks = BrickTier1;
        
        HUDNode *hud = [HUDNode hudAtPosition:CGPointMake(0, self.frame.size.height-20)
                                      inFrame:self.frame];
        [self addChild:hud];
        [hud loadHighScore];
    }
    return self;
}


#pragma mark - Physics Contact Delegate Methods

- (void)didBeginContact:(SKPhysicsContact *)contact {
    // create a placeholder reference for the non-ball object
    SKPhysicsBody *notTheBall;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        notTheBall = contact.bodyB;
    } else {
        notTheBall = contact.bodyA;
    }
    
    if (notTheBall.categoryBitMask == greyBrickCategory) {
        [self removeBrick:GreyBrick onBody:notTheBall];
    }
    
    if (notTheBall.categoryBitMask == redBrickCategory) {
        [self removeBrick:RedBrick onBody:notTheBall];
        
        // add the Red Ball if there is none
        if (!self.redBallInPlay) {
            [self addBall:self.size atPosition:notTheBall.node.position ofType:RedBall];
            self.redBallInPlay = YES;
        }
    }
    
    if (notTheBall.categoryBitMask == blueBrickCategory) {
        [self removeBrick:BlueBrick onBody:notTheBall];
    }
    
    if (notTheBall.categoryBitMask == yellowBrickCategory) {
        
        // add the shield by removing the Bottom Edge
        [self removeBottomEdge:self.size];
        
        // add a yellow graphic to depict the presence yellow shield
        [self drawBottomShield];
        
        // remove the yellow brick - includes any emitter work
        [self removeBrick:YellowBrick onBody:notTheBall];
    }
    
    if (notTheBall.categoryBitMask == paddleCategory) {
        [self runAction:self.paddleSound];
    }
    
    if (notTheBall.categoryBitMask == bottomEdgeCategory) {
        // Game Over
        HUDNode *hud = (HUDNode*)[self childNodeWithName:@"hud"];
        [hud saveHighScore];
        
        EndScene *gameOver = [[EndScene alloc] initWithSize:self.size andScore:hud.score];
        
        [self.view presentScene:gameOver transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }
}


- (void)removeBrick:(int)brickType onBody:(SKPhysicsBody *)body {
    NSArray *brickExplosionArray = @[@"BrickExplosion", @"RedBrickExplosion", @"BlueBrickExplosion", @"BrickExplosion"];
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:brickExplosionArray[brickType] ofType:@"sks"];
    SKEmitterNode *brickExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    brickExplosion.position = body.node.position;
    [self addChild:brickExplosion];
    [brickExplosion runAction:[SKAction waitForDuration:2.0] completion:^{
        [brickExplosion removeFromParent];
        [self ballSpeedAdjust];
        if (self.redBallInPlay) [self redBallSpeedAdjust];
    }];
    
    [body.node removeFromParent];
    
    // increment score
    [self addPoints:BrickPoint]; // the score is the number of demolished bricks
    
    // remove a brick
    self.bricks--;
    [self runAction:self.brickSound];
}


#pragma mark - Check to see if the ball is slowing down or speeding up and adjust

- (void)ballSpeedAdjust {
    SKNode* ball = [self childNodeWithName: @"ball"];
    static int maxSpeed = 600;
    CGVector velocity = ball.physicsBody.velocity;
    float speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
   // NSLog(@"SPEED = %f", speed);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
    if (self.level >= 3) {
        if (speed < 400) [self addImpulse]; // Faster
    } else {
        if (speed < 275) [self addImpulse]; // Normal Speed
    }
}


- (void)redBallSpeedAdjust {
    SKNode* ball = [self childNodeWithName: @"redBall"];
    static int maxSpeed = 800;
    CGVector velocity = ball.physicsBody.velocity;
    float speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
    if (self.level >= 3) {
        if (speed < 500) [self addImpulse]; // Faster
    } else {
        if (speed < 300) [self addImpulse]; // Normal Speed
    }
}


#pragma mark - Add Points to the Score, Save High Score
- (void)addPoints:(NSInteger)points {
    HUDNode *hud = (HUDNode*)[self childNodeWithName:@"hud"];
    [hud addPoints:points];
}


- (NSInteger)checkPoints {
    HUDNode *hud = (HUDNode*)[self childNodeWithName:@"hud"];
    return hud.score;
}


#pragma mark - Update Loop Actions

- (void)update:(NSTimeInterval)currentTime {
    // check to see if we have no more bricks
    
    if (self.bricks <= 0) {
        NSLog(@"Level Complete: %ld", (long)self.level);
        
        // check if level 1 make level 2 by adding 4 bricks
        if (self.level == 1) {
            self.bricks = BrickTier1;
            self.level++;
            [self addBricks:self.size atLevel:BrickTier1];
        }
        
        // level 2 and above get two row of 4 bricks
        if (self.level >= 2) {
            self.bricks = BrickTier2;
            self.level++; // at level 3 used for advanced animation & bricks
            [self addBricks:self.size atLevel:BrickTier2];

            // Add a bit more force to the ball
            // [self addImpulse];
        }
        
        // Point based checking starts with three rows of 4 bricks
        if ([self checkPoints] > AdvancedGamePlay) {
            self.bricks = BrickTier3;
            self.level++;
            [self addBricks:self.size atLevel:BrickTier3];
        }
        
        // remove the red ball if there is one
        if (self.redBallInPlay) {
            SKNode* redball = [self childNodeWithName: @"redball"];
            [redball removeFromParent];
            // put in an explosion
            self.redBallInPlay = NO;
        }
        
        // if the shield was added - remove it now by adding bottom edge
        if (self.bottomEdgeOn) {
            [self addBottomEdge:self.size];
            
            // remove yellow bottom shield graphic
            [self eraseBottomShield];
        }
    }
    [self ballSpeedAdjust];
    if (self.redBallInPlay) [self redBallSpeedAdjust];
}


- (void)didEvaluateActions {
    [self ballSpeedAdjust];
}

- (void)didSimulatePhysics {
    [self ballSpeedAdjust];
}


#pragma mark - Draw Line on the Bottom to depict a protective shield

- (void)drawBottomShield {
    SKSpriteNode *bottomShield = [SKSpriteNode spriteNodeWithImageNamed:@"yellow_line@2x"];
    bottomShield.name = @"bottomShield";
    bottomShield.position = CGPointMake(self.frame.size.width/2, 150);
    
    bottomShield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomShield.frame.size];
    
    // make it static
    bottomShield.physicsBody.dynamic = NO;
    
    [self addChild:bottomShield];
    
    // play a sound like a low hum
}


- (void)eraseBottomShield {
    SKSpriteNode *bottomShield = (SKSpriteNode *)[self childNodeWithName:@"bottomShield"];
    [bottomShield removeFromParent];
    
    // stop playing low hum sound
}

@end
