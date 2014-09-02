//
//  EndScene.m
//  BreakingBricks
//
//  Created by Dulio Denis on 9/1/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "EndScene.h"

@implementation EndScene

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        
        // Game Over Message
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        label.text = @"Game Over";
        label.fontColor = [SKColor whiteColor];
        label.fontSize = 50;
        label.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
        [self addChild:label];
    }
    return self;
}

@end
