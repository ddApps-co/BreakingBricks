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
static const int BrickTier1 = 8;        // Cumulative Number of Bricks in Tiers
static const int BrickTier2 = 16;
static const int BrickTier3 = 24;
static const int BrickTier4 = 32;
static const int BrickTier5 = 40;
static const int BrickTier6 = 48;
static const int BrickTier7 = 56;
static const int BrickTier8 = 64;

// Brick Types
static const int GreyBrick = 0;
static const int RedBrick = 1;
static const int BlueBrick = 2;
static const int YellowBrick = 3;
static const int GreenBrick = 4;
// Game Play
static const int AdvancedGamePlay = 16;      // Advanced Game Play Triggered @Level 3
//static const int AdvancedGamePlayTier1 = 30;
//static const int AdvancedGamePlayTier2 = 40;
//static const int AdvancedGamePlayTier3 = 50;

static const int PointsToGetBall = 10; //Free Ball at this number of Bricks

typedef enum brickColors {
    greyBrick,
    blueBrick,
    yellowBrick,
    redBrick,
    greenBrick
} BrickColor;

@interface MyScene()
@property (nonatomic) SKSpriteNode *paddle;
@property (nonatomic) SKAction *paddleSound;
@property (nonatomic) SKAction *brickSound;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger bricks;
@property (nonatomic) BOOL redBallInPlay;   // Keeps track when the Red Ball is in Play
@property (nonatomic) BOOL bottomEdgeOn;    // Removes the bottome edge (Yellow Power On)
@property (nonatomic) BOOL levelCompletion; // Used as a level completion mode indicator
@property (nonatomic) BOOL yellowBrick;     // Used to ensure only 1 Yellow per Level
@property (nonatomic) BOOL saveLevelOn;     // Restart from last highest level - Pro Mode
@property (nonatomic) NSInteger AGPLevel;   // Advanced Game Play Level
@property (nonatomic) NSInteger specialBricks; // Track the number of special bricks in a level
@property (nonatomic) NSInteger numberOfBalls; // Track how many balls player has
@end


#pragma mark - Categories
static const uint32_t ballCategory        = 0x1 << 0;
//static const uint32_t redBallCategory     = 0x1 << 1;
static const uint32_t greyBrickCategory   = 0x1 << 2;
static const uint32_t redBrickCategory    = 0x1 << 3;
static const uint32_t blueBrickCategory   = 0x1 << 4;
static const uint32_t yellowBrickCategory = 0x1 << 5;
static const uint32_t greenBrickCategory  = 0x1 << 6;
static const uint32_t paddleCategory      = 0x1 << 7;
static const uint32_t edgeCategory        = 0x1 << 8;
static const uint32_t bottomEdgeCategory  = 0x1 << 9;


@implementation MyScene

#pragma mark - Add the Ball, Add Impulse to the Ball

- (void)addBall:(CGSize)size atPosition:(CGPoint)ballPosition ofType:(int)ballType {
    // create a new sprite node from an image
    SKSpriteNode *ball = [SKSpriteNode node];
    if (ballType == GreyBall) {
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ballGrey-7p"];
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
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ballRed-Small"];
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
        ball.physicsBody.contactTestBitMask = redBrickCategory | blueBrickCategory | yellowBrickCategory | greyBrickCategory | greenBrickCategory | paddleCategory | bottomEdgeCategory;
        
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
        CGVector redVector = CGVectorMake(12, 12);
        [redball.physicsBody applyImpulse:redVector];
    }
}


#pragma mark - Add the Player

- (void)addPlayer:(CGSize)size {
    // create paddle sprite
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle-7p"];
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

- (void)addLargeBricks:(CGSize)size atLevel:(NSInteger)brickTier {
    int brickRowPosition, bricksPerRow;
    if (brickTier == BrickTier1) { brickRowPosition= 50;  bricksPerRow = 4; }
    if (brickTier == BrickTier2) { brickRowPosition= 85;  bricksPerRow = 4; }
    if (brickTier == BrickTier3) { brickRowPosition= 120; bricksPerRow = 4; }
    if (brickTier == BrickTier4) { brickRowPosition= 155; bricksPerRow = 4; }
    
    NSInteger numberOfSpecialBricks = 0;
    
    for (int i = 0; i < bricksPerRow; i++) {
        SKSpriteNode *brick = [SKSpriteNode node];
        
        if ([self checkPoints] >= AdvancedGamePlay) {
            NSArray *brickArray = @[@"greyBrick-7p", @"blueDark-7p", @"yellowBrick-7p", @"redBrick-7p"];
            uint32_t brickCategoryArray[4] = {greyBrickCategory, blueBrickCategory, yellowBrickCategory, redBrickCategory};
            
            BrickColor brickTypeNumber ;
            if (self.level == 3) brickTypeNumber = arc4random_uniform(greyBrick);
            if (self.level == 4) brickTypeNumber = arc4random_uniform(blueBrick);
            if (self.level == 5) brickTypeNumber = arc4random_uniform(yellowBrick);
            if (self.level >  5) brickTypeNumber = arc4random_uniform(redBrick);
            
            // if (self.AGPLevel > 4) self.AGPLevel = 4;
            
            // NSUInteger brickTypeNumber = arc4random_uniform(self.AGPLevel);
            
            //if (numberOfSpecialBricks < self.specialBricks) {
                // numberOfSpecialBricks++;
            if ((brickTypeNumber == yellowBrick) && (!self.yellowBrick)) {
                self.yellowBrick = YES;
            } else if ((brickTypeNumber == yellowBrick) && (self.yellowBrick)) {
                brickTypeNumber = greyBrick;
            }
            //} else brickTypeNumber = 0;
            
            NSString *brickType = brickArray[brickTypeNumber];
            brick = [SKSpriteNode spriteNodeWithImageNamed:brickType];
            
            // if a blue brick use the userData to keep a power level
            if (brickTypeNumber == blueBrick) {
                brick.userData = [NSMutableDictionary dictionary];
                [brick.userData setValue:@1 forKey:@"Power"];
            }
            
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = brickCategoryArray[brickTypeNumber];
            
        } else {
            brick = [SKSpriteNode spriteNodeWithImageNamed:@"greyBrick-7p"];
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = greyBrickCategory;
        }
        
        int xPosition = size.width/5 * (i+1);
        int yPosition = size.height - brickRowPosition;
        brick.position = CGPointMake(xPosition, yPosition);
        
        [self addChild:brick];
    }
}


- (int)brickTierGivenLevel:(int)level {// Pts
    if (level == 1) return BrickTier1;
    if (level == 2) return BrickTier2;
    if (level == 3) return BrickTier3;
    if (level == 4) return BrickTier4;
    if (level == 5) return BrickTier5;
    if (level == 6) return BrickTier6;
    if (level == 7) return BrickTier7;
    return BrickTier8;
}


- (int)pointsGivenLevel:(int)level {
    if (level == 1) return 0;
    if (level == 2) return BrickTier1;
    if (level == 3) return BrickTier2;
    if (level == 4) return BrickTier3;
    if (level == 5) return BrickTier4;
    if (level == 6) return BrickTier5;
    if (level == 7) return BrickTier6;
    if (level == 8) return BrickTier7;
    if (level == 9) return BrickTier8;
    return ((level-8) * BrickTier8);   // ex: L10 = (2*64)=128, L11=(3*64)=192
}


- (void)addRowsOfBricks:(int)rows {
    if (rows == 1) {
        [self addBricks:self.size atLevel:BrickTier1];
        self.bricks = BrickTier1;
    }
    if (rows == 2) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        self.bricks = BrickTier2;
    }
    if (rows == 3) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        self.bricks = BrickTier3;
    }
    if (rows == 4) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        [self addBricks:self.size atLevel:BrickTier4];
        self.bricks = BrickTier4;
    }
    if (rows == 5) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        [self addBricks:self.size atLevel:BrickTier4];
        [self addBricks:self.size atLevel:BrickTier5];
        self.bricks = BrickTier5;
    }
    if (rows == 6) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        [self addBricks:self.size atLevel:BrickTier4];
        [self addBricks:self.size atLevel:BrickTier5];
        [self addBricks:self.size atLevel:BrickTier6];
        self.bricks = BrickTier6;
    }
    if (rows == 7) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        [self addBricks:self.size atLevel:BrickTier4];
        [self addBricks:self.size atLevel:BrickTier5];
        [self addBricks:self.size atLevel:BrickTier6];
        [self addBricks:self.size atLevel:BrickTier7];
        self.bricks = BrickTier7;
    }
    if (rows >= 8) {
        [self addBricks:self.size atLevel:BrickTier1];
        [self addBricks:self.size atLevel:BrickTier2];
        [self addBricks:self.size atLevel:BrickTier3];
        [self addBricks:self.size atLevel:BrickTier4];
        [self addBricks:self.size atLevel:BrickTier5];
        [self addBricks:self.size atLevel:BrickTier6];
        [self addBricks:self.size atLevel:BrickTier7];
        [self addBricks:self.size atLevel:BrickTier8];
        self.bricks = BrickTier8;
    }
    self.specialBricks++;
}

- (void)addBricks:(CGSize)size atLevel:(NSInteger)brickTier {
    int brickRowPosition, bricksPerRow;
    if (brickTier == BrickTier1) { brickRowPosition= 50;  bricksPerRow = 8; }
    if (brickTier == BrickTier2) { brickRowPosition= 75;  bricksPerRow = 8; }
    if (brickTier == BrickTier3) { brickRowPosition= 100; bricksPerRow = 8; }
    if (brickTier == BrickTier4) { brickRowPosition= 125; bricksPerRow = 8; }
    if (brickTier == BrickTier5) { brickRowPosition= 150; bricksPerRow = 8; }
    if (brickTier == BrickTier6) { brickRowPosition= 175; bricksPerRow = 8; }
    if (brickTier == BrickTier7) { brickRowPosition= 200; bricksPerRow = 8; }
    if (brickTier == BrickTier8) { brickRowPosition= 225; bricksPerRow = 8; }
    
    NSInteger numberOfSpecialBricks = 0;
    
    for (int i = 0; i < bricksPerRow; i++) {
        SKSpriteNode *brick = [SKSpriteNode node];
        
        //if ([self checkPoints] >= AdvancedGamePlay) {
        if (self.specialBricks) {
            NSArray *brickArray = @[@"greyBrickSmall", @"blueDarkSmall", @"yellowSmallBrick", @"greenBrickSmall", @"redBrickSmall"];
            uint32_t brickCategoryArray[5] = {greyBrickCategory, blueBrickCategory, yellowBrickCategory, greenBrickCategory, redBrickCategory};
            
            BrickColor brickTypeNumber ;
            if (self.level == 3) brickTypeNumber = arc4random_uniform(greyBrick);
            if (self.level == 4) brickTypeNumber = arc4random_uniform(blueBrick);
            if (self.level == 5) brickTypeNumber = arc4random_uniform(yellowBrick);
            if (self.level == 6) brickTypeNumber = arc4random_uniform(greenBrick);
            if (self.level >= 7) brickTypeNumber = arc4random_uniform(redBrick);
            
            // if (self.AGPLevel > 4) self.AGPLevel = 4;
            
            // NSUInteger brickTypeNumber = arc4random_uniform(self.AGPLevel);
            
            //if (numberOfSpecialBricks < self.specialBricks) {
            // numberOfSpecialBricks++;
            
            // Only 1 Yellow Brick per Level
            if ((brickTypeNumber == yellowBrick) && (!self.yellowBrick)) {
                self.yellowBrick = YES;
            } else if ((brickTypeNumber == yellowBrick) && (self.yellowBrick)) {
                brickTypeNumber = greyBrick;
            }
            //} else brickTypeNumber = 0;
            
            NSString *brickType = brickArray[brickTypeNumber];
            brick = [SKSpriteNode spriteNodeWithImageNamed:brickType];
            
            // if a blue brick use the userData to keep a power level
            if (brickTypeNumber == blueBrick) {
                brick.userData = [NSMutableDictionary dictionary];
                [brick.userData setValue:@1 forKey:@"Power"];
            }
            
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = brickCategoryArray[brickTypeNumber];
            
        } else {
            brick = [SKSpriteNode spriteNodeWithImageNamed:@"greyBrickSmall"];
            // add a static physics body
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            
            // add category
            brick.physicsBody.categoryBitMask = greyBrickCategory;
        }
        
        int xPosition = size.width/9 * (i+1);
        int yPosition = size.height - brickRowPosition;
        brick.position = CGPointMake(xPosition, yPosition);
        
        [self addChild:brick];
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
        self.bottomEdgeOn = YES; // NO for testing, YES for Production
        
        // Save the Highest Level - IAP of Pro Mode
        self.saveLevelOn = YES;
        
        // read highest level
        if (self.saveLevelOn) {
            long savedLevel = [self loadHighLevel];
            if (!savedLevel) self.level = 1; // the initial time
            else  {
                self.level = [self loadHighLevel];
                [self addPoints:(int)[self pointsGivenLevel:(int)self.level]];
            }
        }
        
        // add the objects to the scene
        [self addBall:size atPosition:CGPointZero ofType:GreyBall];
        [self addPlayer:size];
        [self addRowsOfBricks:(int)self.level];
        [self addBottomEdge:size];
        
        // preload sound effects
        
        self.paddleSound = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
        self.brickSound = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
        
        // initialize level and bricks: Level 1 = 4 Bricks
        // self.level = 1;
        self.bricks = (int)[self brickTierGivenLevel:(int)self.level];
        
        HUDNode *hud = [HUDNode hudAtPosition:CGPointMake(0, self.frame.size.height-20)
                                      inFrame:self.frame];
        [self addChild:hud];
        [hud loadHighScore];
        
        self.levelCompletion = NO; // set to no in level completion mode
        self.yellowBrick = NO;     // set to no Yellow Brick Yet
        self.specialBricks = 0;    // initialize the number of special bricks to zero
        
        self.numberOfBalls = 0; // start the player with no extra lives - earn it
    }
    return self;
}


#pragma mark - Load and Save Highest Level to enable Pro Mode
// to truly continue need to restore level, score(?), and special bricks
// score is the number of levels x 48
// L1(8), L2(

- (void)saveHighLevel {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    long value;
    value = [prefs integerForKey:@"highLevel"];
    
    if (self.level > value) {
        // write the new high level
        [prefs setInteger:self.level forKey:@"highLevel"];
        [prefs synchronize];
    }
}


- (long)loadHighLevel {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs integerForKey:@"highLevel"];
}


#pragma mark - Physics Contact Collision Delegate Methods

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
    
    // the blue brick takes two hits to eliminate
    if (notTheBall.categoryBitMask == blueBrickCategory) {
        NSNumber *powerLevel = (NSNumber *)[notTheBall.node.userData objectForKey:@"Power"];
        if ([powerLevel isEqual:@1]) {
            [notTheBall.node.userData setValue:@0 forKey:@"Power"];
            SKAction* changeColor = [SKAction setTexture:[SKTexture textureWithImageNamed:@"blueLight-7p"]];
            [notTheBall.node runAction:changeColor];
            
            // blue some effect
            NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"BlueSmoke" ofType:@"sks"];
            SKEmitterNode *blueSmoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
            blueSmoke.position = notTheBall.node.position;
            [self addChild:blueSmoke];
            
            // should use a smoke sound
            [self runAction:self.brickSound];
            
            [blueSmoke runAction:[SKAction waitForDuration:2.5] completion:^{
                [blueSmoke removeFromParent];
                [self ballSpeedAdjust];
                if (self.redBallInPlay) [self redBallSpeedAdjust];
            }];
            
        } else {
            [self removeBrick:BlueBrick onBody:notTheBall];
        }
    }
    
    // the green brick explodes and shrinks the paddle
    if (notTheBall.categoryBitMask == greenBrickCategory) {
        [self greenPaddleSwitch];
        [self removeBrick:GreenBrick onBody:notTheBall];
    }
    
    if (notTheBall.categoryBitMask == yellowBrickCategory) {
        
        // add the shield by removing the Bottom Edge
        // the shield is so large this is not needed anymore
        // [self removeBottomEdge:self.size];
        
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
        
        if (self.saveLevelOn) {
            [self saveHighLevel];
        }
        
        EndScene *gameOver = [[EndScene alloc] initWithSize:self.size andScore:hud.score];
        
        [self.view presentScene:gameOver transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }
}


- (void)removeBrick:(int)brickType onBody:(SKPhysicsBody *)body {
    NSArray *brickExplosionArray = @[@"BrickExplosion", @"RedBrickExplosion", @"BlueBrickExplosion", @"BrickExplosion", @"GreenBrickExplosion"];
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
    
    // check to see if we achieved a new ball
    int currentPoints = [self checkPoints];
    int newBallCount = currentPoints % PointsToGetBall;
    if (newBallCount > self.numberOfBalls) {
        // play new ball sound
        
        self.numberOfBalls = newBallCount;
    }
    
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
    static int maxSpeed = 350;
    CGVector velocity = ball.physicsBody.velocity;
    float speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy);
    if (speed > maxSpeed) {
        ball.physicsBody.linearDamping = 0.4f;
    } else {
        ball.physicsBody.linearDamping = 0.0f;
    }
    if (self.level >= 3) {
        if (speed < 100) [self addImpulse]; // Faster
    } else {
        if (speed < 50) [self addImpulse]; // Normal Speed
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
    // check to see if we have no more bricks and not in level completion mode
    if (self.bricks <= 0 && !self.levelCompletion) {
        self.levelCompletion = YES;
        [self removeBall];
        NSLog(@"Level Complete: %ld", (long)self.level);
            
        SKLabelNode *levelCompleteLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        levelCompleteLabel.name = @"levelCompletion";
        levelCompleteLabel.text = [NSString stringWithFormat:@"Level %ld Complete", (long)self.level];
        levelCompleteLabel.fontColor = [SKColor whiteColor];
        levelCompleteLabel.fontSize = 24;
        levelCompleteLabel.position = CGPointMake(self.size.width/2, self.size.height);
        
        SKAction *moveLabel = [SKAction moveToY:(self.size.height/2) duration:2.0];
        [levelCompleteLabel runAction:moveLabel completion:^{
            [self levelCompletionCheck];
            [self ballSpeedAdjust];
            if (self.redBallInPlay) [self redBallSpeedAdjust];
            self.levelCompletion = NO; // reset in the completion handler
            [levelCompleteLabel removeFromParent];
            
            [self addBall:self.size atPosition:CGPointZero ofType:GreyBall];
        }];
        
        [self addChild:levelCompleteLabel];
    }
}


- (void)removeBall {
    SKNode* ball = [self childNodeWithName: @"ball"];
    [ball removeFromParent];
    // ball remove sound
}


- (void)levelCompletionCheck {
    // check if level 1 make level 2 by adding two rows of 4 bricks
    if (self.level == 1) {
        self.bricks = BrickTier2;
        self.level++;
        [self addRowsOfBricks:BrickTier2];
    }
    
    // above level 2 get two rows of 4 bricks each
    else if ((self.level >= 2) && (self.level < 3)) {
        self.bricks = BrickTier3;
        self.level++;
        
        if (self.level > 2) self.AGPLevel++;
        NSLog(@"AGP Level = %d", self.AGPLevel);
        self.specialBricks++; // increment the number of special bricks
        NSLog(@"special bricks = %d", self.specialBricks);
        
        [self addRowsOfBricks:BrickTier3];
    }
    
    // level 5 get two rows of 4 bricks each
    else if (self.level >= 3) {
        self.bricks = BrickTier4;
        self.level++;
        
        if (self.level > 5) self.AGPLevel++;
        NSLog(@"AGP Level = %d", self.AGPLevel);
        self.specialBricks++; // increment the number of special bricks
        NSLog(@"special bricks = %d", self.specialBricks);
        
        [self addRowsOfBricks:BrickTier4];
    }
    
    // remove the red ball if there is one
    if (self.redBallInPlay) {
        SKNode* redball = [self childNodeWithName: @"redball"];
        [redball removeFromParent];
        // put in an explosion
        self.redBallInPlay = NO;
    }
    
    // if the shield was added - remove it now by adding bottom edge
    // if (self.bottomEdgeOn) {
    //     [self addBottomEdge:self.size];
    // }
    
    // if there was a Yellow Brick - reset and remove the shield
    if (self.yellowBrick) {
        self.yellowBrick = NO;
        // remove yellow bottom shield graphic
        [self eraseBottomShield];
    }

}


- (void)didEvaluateActions {
    [self ballSpeedAdjust];
}


- (void)didSimulatePhysics {
    [self ballSpeedAdjust];
}


#pragma mark - Draw Line on the Bottom to depict a protective shield

- (void)drawBottomShield {
    SKSpriteNode *bottomShield = [SKSpriteNode spriteNodeWithImageNamed:@"yellowShield-Small"];
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


- (void)greenPaddleSwitch {
    SKNode* paddle = [self childNodeWithName: @"paddle"];
    SKAction* changeColor = [SKAction setTexture:[SKTexture textureWithImageNamed:@"paddleGreen-Small"]];
    [paddle runAction:changeColor];
}

@end
