//
//  HUDNode.h
//  BreakingBricks
//
//  Created by Dulio Denis on 9/2/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HUDNode : SKNode

@property (nonatomic) NSInteger level;  // current level
@property (nonatomic) NSInteger score; // total number of bricks demolished

+ (instancetype)hudAtPosition:(CGPoint)position inFrame:(CGRect)frame;
- (void)addPoints:(NSInteger)points;
- (void)saveHighScore;
- (void)loadHighScore;

@end
