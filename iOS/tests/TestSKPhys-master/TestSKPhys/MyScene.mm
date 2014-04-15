//
//  MyScene.m
//  TestSKPhys
//
//  Created by James Norton on 9/17/13.
//  Copyright (c) 2013 James Norton. All rights reserved.
//

#import "MyScene.h"
#import <Box2D.h>

//#define BOX2D
#define NUM_BOXES (0)
#define PIXELS_PER_METER (150)
#define SMALL_BOX_WIDTH (10)
#define BIG_BOX_WIDTH (50)
#define SMALL_BOX_HEIGHT (SMALL_BOX_WIDTH / 1)
#define BIG_BOX_HEIGHT (BIG_BOX_WIDTH / 1)
#define ANGULAR_VELOCITY (0)
#define ANGULAR_DAMPING (0)
#define LINEAR_DAMPING (0)
#define DENSITY (1.0)
#define FRICTION (0.1)
#define RESTITUTION (0.1)
#define GRAVITY (-1.5)
#define EPSILON (0)//.05)
#define RANDOM_SIZE
//#define GRID_LAYOUT_FOR_CREATION

float boxWidth = BIG_BOX_WIDTH;
float boxHeight = BIG_BOX_HEIGHT;

@implementation MyScene {
    b2World *world;
    double accumulator;
    double timeStep;
    double prevTime;
    int frameCount;
    float g;
    BOOL frameRateDisplayed;
    double physicsStartTime;
    double physicsEndTime;
    double simualtionTime;
    double sampleStartTime;
    
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        timeStep = 1.0 / 60.0;
        accumulator = 0;
        prevTime = -1;
        frameCount = 0;
        g = GRAVITY;
        frameRateDisplayed = NO;
        physicsStartTime = 0;
        physicsEndTime = 0;
        sampleStartTime = 0;
        
#ifdef BOX2D
        NSLog(@"Box2D Elastic - %d boxes", NUM_BOXES);
        
        b2Vec2 gravity(0.0f, g);
        bool doSleep = true;
        world = new b2World(gravity);
        world->SetAllowSleeping(doSleep);
        b2Vec2 vs[5];
        
        vs[0].Set(0, 0.0f);
        
        vs[1].Set(size.width / PIXELS_PER_METER, 0);
        
        vs[2].Set(size.width / PIXELS_PER_METER, size.height / PIXELS_PER_METER);
        
        vs[3].Set(0, size.height / PIXELS_PER_METER);
        
        vs[4].Set(0, 0);
        
        
        
        b2ChainShape chain;
        
        chain.CreateChain(vs, 5);
        
        b2BodyDef boundaryDef;
        boundaryDef.position.Set(0,0);
        b2Body *boundary = world->CreateBody(&boundaryDef);
        boundary->CreateFixture(&chain, 0);
        
#else
        NSLog(@"SKPhysics Elastic - %d boxes", NUM_BOXES);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, g);
        self.physicsWorld.contactDelegate = self;
#endif
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        [self addBoxes];
        
    }
    return self;
}

-(void)addBoxes {
    float xStart = boxWidth - 3;
    float yStart = self.size.height-2*boxHeight;

    int rowSize = self.size.width / (boxWidth + 5);
    
    CGRect stageRect = [[UIScreen mainScreen] bounds];
    
    for(int i = 0;i<NUM_BOXES;i++) {
#ifdef GRID_LAYOUT_FOR_CREATION
        float x = (i % rowSize) * (boxWidth + 5) + xStart;
        float y = yStart - (i / rowSize) * (boxHeight * 1.5);
        [self addBoxAtX:x Y:y];
#else
        [self addBoxAtX:arc4random_uniform(stageRect.size.width) Y:arc4random_uniform(stageRect.size.height*.3) + stageRect.size.height*.5 Size:CGSizeMake(boxWidth, boxHeight)];
#endif
        
        
    }
}


- (void)addBoxAtX:(float )x Y:(float)y Size:(CGSize)size {
    NSLog(@"new size %@",NSStringFromCGSize(size));
    SKSpriteNode *Box = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor] size:size];
    Box.position = CGPointMake(x, y);
    Box.name = @"Box";
    
#ifdef BOX2D
    
    b2BodyDef bodyDef;
    bodyDef.position.Set(Box.position.x / PIXELS_PER_METER, Box.position.y / PIXELS_PER_METER);
    //bodyDef.angle = DEG_TO_RAD(obj.rotation);
    
    b2BodyType type = b2_dynamicBody;
    
   
    
    bodyDef.type = type;
    
    bodyDef.linearDamping = 0;
    bodyDef.angularDamping = 0;
    bodyDef.allowSleep = true;
    bodyDef.awake = true;
    
    b2Body* body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    b2PolygonShape polyShape;
        
        
    float gapRemove = 0;//.005f;
    polyShape.SetAsBox((Box.size.width / 2.0 / PIXELS_PER_METER)-gapRemove, (Box.size.height / 2.0 / PIXELS_PER_METER)-gapRemove);
    fixtureDef.shape = &polyShape;
    
    fixtureDef.density = DENSITY;
    fixtureDef.friction = FRICTION;
    fixtureDef.restitution = RESTITUTION;
    fixtureDef.isSensor = 0;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData((__bridge void*)Box);
    
    //body->SetAngularVelocity(6.28);
    body->SetAngularVelocity(ANGULAR_VELOCITY);
    body->SetAngularDamping(ANGULAR_DAMPING);
    body->SetLinearDamping(LINEAR_DAMPING);
    
#else
    Box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:Box.size];
    Box.physicsBody.angularVelocity = ANGULAR_VELOCITY;
    Box.physicsBody.angularDamping = ANGULAR_DAMPING;
    Box.physicsBody.restitution = RESTITUTION;
    Box.physicsBody.density = DENSITY;
    Box.physicsBody.friction = FRICTION;
    Box.physicsBody.linearDamping = LINEAR_DAMPING;
    Box.physicsBody.categoryBitMask = 10;
    Box.physicsBody.collisionBitMask = 10;
    Box.physicsBody.contactTestBitMask = 10;
    Box.name = @"Box";
#endif
    
    [self addChild:Box];
    
}


#ifdef BOX2D
void updatePhysics(double deltaT, double &accumulator, double timeStep, b2World *world) {
    int velocityIterations = 8;
    int positionIterations = 3;
    //int velocityIterations = 10;
    //int positionIterations = 10;
    
    
    if (deltaT > 0.25) {
        deltaT = 0.25;// note: max frame time to avoid spiral of death
    }
    
    accumulator += deltaT;
    
    while ( accumulator >= timeStep ) {
        if (accumulator < timeStep * 2.0) {
            // only update if on last simulation loop
            
            
            for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
                SKSpriteNode *sprite = (__bridge SKSpriteNode *)b->GetUserData();
                b2Vec2 position = b->GetPosition();
                
                CGPoint pos = CGPointMake(position.x*PIXELS_PER_METER, position.y*PIXELS_PER_METER);
                sprite.position = pos;
                
                float32 angle = b->GetAngle();
                
                sprite.zRotation = angle;
                
                
                //GemLog(@"(x,y,theta) = (%4.2f, %4.2f, %4.2f)\n", position.x, position.y, angle);
            }
           
            
            
        }
        
        
        world->Step(timeStep, velocityIterations, positionIterations);
        
        
        accumulator -= timeStep;
    }
    
    // interpolate remainder of update
    const double alpha = accumulator / timeStep;
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
        SKSpriteNode *sprite = (__bridge SKSpriteNode *)b->GetUserData();
        b2Vec2 position = b->GetPosition();
        CGPoint pos = CGPointMake((position.x * PIXELS_PER_METER +(1.0 - alpha) * sprite.position.x/PIXELS_PER_METER),
                                  (position.y * PIXELS_PER_METER + (1.0 - alpha)*sprite.position.y/PIXELS_PER_METER));
        sprite.position = pos;
        
        //NSLog(@"x = %f   y = %f", pos.x, pos.y);
        
        float32 angle = b->GetAngle();
        sprite.zRotation = alpha * angle + (1.0-alpha)*sprite.zRotation;
       
    }
    
};
#endif

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint pos = [touch locationInNode:self];
        CGSize size;
#ifdef RANDOM_SIZE
        float newBoxWidth = arc4random_uniform(boxWidth*.8)+ (boxWidth*.2);
        size = CGSizeMake(newBoxWidth, newBoxWidth);
#else
        size = CGSizeMake(boxWidth,boxHeight);
#endif
        [self addBoxAtX:pos.x Y:pos.y Size:size];
        
    }
}

#ifndef BOX2D
-(void)didEvaluateActions {
    physicsStartTime = [NSDate timeIntervalSinceReferenceDate];
    if (sampleStartTime == 0) {
        sampleStartTime = physicsStartTime;
    }
}

-(void)didSimulatePhysics {
    physicsEndTime = [NSDate timeIntervalSinceReferenceDate];
    frameCount++;
    
    simualtionTime += (physicsEndTime - physicsStartTime);
    if (physicsEndTime - sampleStartTime > 1.0 - EPSILON) {
//        NSLog(@"Average simulation time = %f", (simualtionTime / (double)frameCount));
        simualtionTime = 0;
        sampleStartTime = 0;
        frameCount = 0;
    }
    
}

#else

-(void)update:(CFTimeInterval)currentTime {
    

    /* Called before each frame is rendered */
    if (prevTime == -1) {
        prevTime = currentTime;
    }
    double deltaT = currentTime - prevTime;
    
    if (deltaT > 0) {
        
        physicsStartTime = [NSDate timeIntervalSinceReferenceDate];
        if (sampleStartTime == 0) {
            sampleStartTime = physicsStartTime;
        }
        updatePhysics(deltaT, accumulator, timeStep, world);
        physicsEndTime = [NSDate timeIntervalSinceReferenceDate];
        frameCount++;
        
        simualtionTime += (physicsEndTime - physicsStartTime);
        if (physicsEndTime - sampleStartTime > 1.0 - EPSILON) {
//            NSLog(@"Average simulation time = %f", (simualtionTime / (double)frameCount));
            simualtionTime = 0;
            sampleStartTime = 0;
            frameCount = 0;
        }
        
    }
    
    
    prevTime = currentTime;


}

#endif


- (void)didBeginContact:(SKPhysicsContact *)contact {
//    SKPhysicsBody *testA = contact.bodyA;
    SKNode *nodeA = contact.bodyA.node;
    SKNode *nodeB = contact.bodyB.node;
    
    if(nodeA && nodeB){
        if([nodeA.name isEqualToString:@"Box"] && [nodeB.name isEqualToString:@"Box"]){

            float nodeASurface = nodeA.frame.size.width * nodeA.frame.size.height;//CGSizeMake(nodeA.xScale * nodeA.frame.size.width, nodeA.yScale * nodeA.frame.size.height);
            float nodeBSurface = nodeB.frame.size.width * nodeB.frame.size.height;//CGSizeMake(nodeB.xScale * nodeB.frame.size.width, nodeB.yScale * nodeB.frame.size.height);
            float nodeCombinedSurface = sqrtf(nodeASurface + nodeBSurface);
            CGSize newSize = CGSizeMake(nodeCombinedSurface, nodeCombinedSurface);// CGSizeMake(nodeASize.width + nodeBSize.width, nodeASize.height + nodeBSize.height);
            
//            NSLog(@"scale nodeA = %f/%f  nodeB = %f/%f", nodeA.xScale,nodeA.yScale,nodeB.xScale,nodeB.yScale);
//            NSLog(@"size nodeA = %f/%f  nodeB = %f/%f", nodeA.frame.size.width,nodeA.frame.size.height,nodeB.frame.size.width,nodeB.frame.size.height);
//            NSLog(@"new size = %@", NSStringFromCGSize(newSize));
//            NSLog(@"-----");
            
            
            CGPoint newPos;
//            if(nodeA.position.y < nodeB.position.y){
            if(nodeASurface > nodeBSurface){
                newPos = nodeA.position;
            } else {
                newPos = nodeB.position;
            }
            
            [self addBoxAtX:newPos.x Y:newPos.y Size:newSize];
            
            [nodeA removeFromParent];
            [nodeB removeFromParent];
        }
    }
//    if(testA){
//        NSLog(@"test is there!");
//    }
//    [nodeA removeFromParent];
//    [nodeB removeFromParent];
    //    removeFromParent
    
//    NSLog(@"contact");
}

@end
