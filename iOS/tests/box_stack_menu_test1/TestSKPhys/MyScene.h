//
//  MyScene.h
//  TestSKPhys
//

//  Copyright (c) 2013 James Norton. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

typedef void (^createBoxBlock)(void);

@interface MyScene : SKScene <SKPhysicsContactDelegate>

- (id) initWithSize:(CGSize)size MotionManager:(CMMotionManager *)motionManager;
@end
