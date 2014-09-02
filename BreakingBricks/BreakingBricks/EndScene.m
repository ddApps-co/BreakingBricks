//
//  EndScene.m
//  BreakingBricks
//
//  Created by Dulio Denis on 9/1/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "EndScene.h"
#import "MyScene.h"

@implementation EndScene

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        
        SKAction *gameOverSound = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
        [self runAction:gameOverSound];
        
        // Game Over Message
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text = @"Game Over";
        label.fontColor = [SKColor blackColor];
        label.fontSize = 50;
        label.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
        [self addChild:label];
        
        // add a second label
        SKLabelNode *tryAgain = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        tryAgain.text = @"Tap to Play Again";
        tryAgain.fontColor = [SKColor blackColor];
        tryAgain.fontSize = 24;
        tryAgain.position = CGPointMake(size.width/2, -50);
        
        SKAction *moveLabel = [SKAction moveToY:(size.height/2 - 40) duration:1.0];
        [tryAgain runAction:moveLabel];
        
        [self addChild:tryAgain];
    }
    return self;
}

// tap to return to the game scene
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    MyScene *gameScene = [MyScene sceneWithSize:self.size];
    [self.view presentScene:gameScene transition:[SKTransition doorwayWithDuration:1.0]];
}

@end
