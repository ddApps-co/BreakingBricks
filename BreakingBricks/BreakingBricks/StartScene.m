//
//  StartScene.m
//  BreakingBricks
//
//  Created by Dulio Denis on 9/13/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "StartScene.h"
#import "MyScene.h"

@implementation StartScene


- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        
        // add the game label
        SKLabelNode *gameLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        gameLabel.text = [NSString stringWithFormat:@"Bricked"];
        gameLabel.fontColor = [SKColor blackColor];
        gameLabel.fontSize = 50;
        gameLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                        CGRectGetMidY(self.frame));
        [self addChild:gameLabel];
        
        // add an instruction label
        SKLabelNode *instructionLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        instructionLabel.text = @"Tap to Start Game";
        instructionLabel.fontColor = [SKColor blackColor];
        instructionLabel.fontSize = 24;
        instructionLabel.position = CGPointMake(size.width/2, CGRectGetMidY(self.frame) -50);
        
        [self addChild:instructionLabel];
        
    }
    return self;
}

// tap to enter the game scene
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    MyScene *gameScene = [MyScene sceneWithSize:self.size];
    [self.view presentScene:gameScene transition:[SKTransition doorwayWithDuration:1.0]];
}

@end
