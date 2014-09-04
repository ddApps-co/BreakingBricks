//
//  ViewController.m
//  BreakingBricks
//
//  Created by Dulio Denis on 8/31/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
        
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        // Create and configure the scene.
        SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (BOOL)shouldAutorotate
{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
