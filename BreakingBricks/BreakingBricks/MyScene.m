//
//  MyScene.m
//  BreakingBricks
//
//  Created by Dulio Denis on 8/31/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "MyScene.h"
#import "EndScene.h"

@interface MyScene()
@property (nonatomic) SKSpriteNode *paddle;
@property (nonatomic) SKAction *paddleSound;
@property (nonatomic) SKAction *brickSound;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger bricks;
@end


#pragma mark - Categories
static const uint32_t ballCategory       = 0x1;
static const uint32_t brickCategory      = 0x1 << 1;
static const uint32_t paddleCategory     = 0x1 << 2;
static const uint32_t edgeCategory       = 0x1 << 3;
static const uint32_t bottomEdgeCategory = 0x1 << 4;


@implementation MyScene

#pragma mark - Add the Ball

- (void)addBall:(CGSize)size {
    // create a new sprite node from an image
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    
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
    ball.physicsBody.contactTestBitMask = brickCategory | paddleCategory | bottomEdgeCategory;
    
    // add the collision bitmask of the edge and the brick - ball passes right thru paddle
    // ball.physicsBody.collisionBitMask = edgeCategory | brickCategory;
    
    // add the sprite node to the scene
    [self addChild:ball];
    
    // create a vector
    CGVector vector = CGVectorMake(10, 10);
    //apply the vector
    [ball.physicsBody applyImpulse:vector];
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

- (void)addBricks:(CGSize)size {
    for (int i = 0; i < 4; i++) {
        SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:@"brick"];
        
        // add a static physics body
        brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
        brick.physicsBody.dynamic = NO;
        
        // add category
        brick.physicsBody.categoryBitMask = brickCategory;
        
        int xPosition = size.width/5 * (i+1);
        int yPosition = size.height - 50;
        brick.position = CGPointMake(xPosition, yPosition);
        
        [self addChild:brick];
    }
}


#pragma mark - Add Bottom Edge

- (void)addBottomEdge:(CGSize)size {
    SKNode *bottomEdge = [SKNode node];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1)
                                                          toPoint:CGPointMake(size.width, 1)];
    bottomEdge.physicsBody.categoryBitMask = bottomEdgeCategory;
    [self addChild:bottomEdge];
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
        
        // add the objects to the scene
        [self addBall:size];
        [self addPlayer:size];
        [self addBricks:size];
        [self addBottomEdge:size];
        
        // preload sound effects
        self.paddleSound = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
        self.brickSound = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
        
        // initialize level and bricks
        self.level = 1;
        self.bricks = 4;
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
    
    if (notTheBall.categoryBitMask == brickCategory) {
        NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"BrickExplosion" ofType:@"sks"];
        SKEmitterNode *brickExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath ];
        brickExplosion.position = notTheBall.node.position;
        [self addChild:brickExplosion];
        [brickExplosion runAction:[SKAction waitForDuration:2.0] completion:^{
            [brickExplosion removeFromParent];
        }];
        
        [notTheBall.node removeFromParent];
        
        // remove a brick
        self.bricks--;
        
        [self runAction:self.brickSound];
    }
    
    if (notTheBall.categoryBitMask == paddleCategory) {
        [self runAction:self.paddleSound];
    }
    
    if (notTheBall.categoryBitMask == bottomEdgeCategory) {
        // Game Over
        EndScene *gameOver = [EndScene sceneWithSize:self.size];
        [self.view presentScene:gameOver transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }
}


#pragma mark - Update Loop Actions

- (void)update:(NSTimeInterval)currentTime {
    // check to see if we have no more bricks
    if (self.bricks == 0) {
        NSLog(@"Level Complete: %d", self.level);
        self.bricks = 4;
        self.level++;
        [self addBricks:self.size];
    }
}

@end
