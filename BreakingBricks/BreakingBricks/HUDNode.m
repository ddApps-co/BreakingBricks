//
//  HUDNode.m
//  BreakingBricks
//
//  Created by Dulio Denis on 9/2/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "HUDNode.h"

@implementation HUDNode

#pragma mark - Initialize Head's Up Display

+ (instancetype)hudAtPosition:(CGPoint)position inFrame:(CGRect)frame {
    HUDNode *hud = [self node];
    hud.position = position;
    hud.zPosition = 10;
    hud.name = @"hud";
    
    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
    highScoreLabel.name = @"HighScore";
   // highScoreLabel.text = [NSString stringWithFormat:@"High Score = %d", self.highScore];
    highScoreLabel.text = [NSString stringWithFormat:@"High = %d", 0];
    highScoreLabel.fontSize = 24;
    highScoreLabel.fontColor = [SKColor whiteColor];
    highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    highScoreLabel.position = CGPointMake(frame.size.width-300, -10);
    [hud addChild:highScoreLabel];
    
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
    scoreLabel.name = @"Score";
    scoreLabel.text = @"0";
    scoreLabel.fontSize = 24;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    scoreLabel.position = CGPointMake(frame.size.width-20, -10);
    [hud addChild:scoreLabel];
    
    return hud;
}

#pragma mark - Award Points, Save & Load High Scores

- (void)addPoints:(NSInteger)points {
    self.score += points;
    SKLabelNode *scoreLabel = (SKLabelNode*)[self childNodeWithName:@"Score"];
    
    scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
}


- (void)saveHighScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int value;
    value = [prefs integerForKey:@"highScore"];
    
    if (self.score > value) {
        // write the new high score
        [prefs setInteger:self.score forKey:@"highScore"];
        [prefs synchronize];
    }
}


- (void)loadHighScore {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int value = [prefs integerForKey:@"highScore"];
    
    SKLabelNode *highScoreLabel = (SKLabelNode*)[self childNodeWithName:@"HighScore"];
    
    highScoreLabel.text = [NSString stringWithFormat:@"High: %d", value];
}

@end
