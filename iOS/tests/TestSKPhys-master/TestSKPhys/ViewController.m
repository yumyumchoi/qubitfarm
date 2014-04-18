//
//  ViewController.m
//  TestSKPhys
//
//  Created by James Norton on 9/17/13.
//  Copyright (c) 2013 James Norton. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import <CoreMotion/CoreMotion.h>

@implementation ViewController {
    CMMotionManager *_motionManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    if (_motionManager == nil) {
//        _motionManager = [[CMMotionManager alloc] init];
//    }
//    
//    // Turn on the appropriate type of data
//    _motionManager.accelerometerUpdateInterval = 0.01;
//    _motionManager.deviceMotionUpdateInterval = 0.01;
//    
//    [_motionManager startDeviceMotionUpdates];
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    MyScene * scene = [[MyScene alloc] initWithSize:skView.bounds.size MotionManager:nil];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"SHAKEN");
    } 
}


@end
