//
//  MyScene.m
//  TestSKPhys
//
//  Created by James Norton on 9/17/13.
//  Copyright (c) 2013 James Norton. All rights reserved.
//

#import "MyScene.h"
#import <Box2D.h>

#define BOX2D
#define NUM_BOXES (0)
#define PIXELS_PER_METER (150)
#define SMALL_BOX_WIDTH (10)
#define BIG_BOX_WIDTH (10)
#define SMALL_BOX_HEIGHT (SMALL_BOX_WIDTH / 1)
#define BIG_BOX_HEIGHT (BIG_BOX_WIDTH / 1)
#define ANGULAR_VELOCITY (0)
#define ANGULAR_DAMPING (0)
#define LINEAR_DAMPING (0)
#define DENSITY (1.0)
#define FRICTION (0.1)
#define RESTITUTION (0.1)
#define GRAVITY (-1.5)
#define EPSILON (.05)
//#define RANDOM_SIZE
//#define GRID_LAYOUT_FOR_CREATION

float boxWidth = BIG_BOX_WIDTH;
float boxHeight = BIG_BOX_HEIGHT;

@implementation MyScene {
    b2World *_world;
    double _accumulator;
    double _timeStep;
    double prevTime;
    int frameCount;
    float g;
    BOOL frameRateDisplayed;
    double physicsStartTime;
    double physicsEndTime;
    double simualtionTime;
    double sampleStartTime;
    NSMutableArray *_boxes;
    NSMutableArray *_bodyToRemove;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        _timeStep = 1.0 / 60.0;
        _accumulator = 0;
        prevTime = -1;
        frameCount = 0;
        g = GRAVITY;
        frameRateDisplayed = NO;
        physicsStartTime = 0;
        physicsEndTime = 0;
        sampleStartTime = 0;
        
//        _boxes = [[NSMutableArray alloc] init];
        
        
        
#ifdef BOX2D
        NSLog(@"Box2D Elastic - %d boxes", NUM_BOXES);
        
        b2Vec2 gravity(0.0f, g);
        bool doSleep = true;
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
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
        b2Body *boundary = _world->CreateBody(&boundaryDef);
        boundary->CreateFixture(&chain, 0);
        
        
        _bodyToRemove = [[NSMutableArray alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(onTickForBox2D:) userInfo:nil repeats:YES];
        
#else
        NSLog(@"SKPhysics Elastic - %d boxes", NUM_BOXES);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, g);
        self.physicsWorld.contactDelegate = self;
        
        _boxes = [[NSMutableArray alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(onTickForSK:) userInfo:nil repeats:YES];
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
    
    b2Body* body = _world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    b2PolygonShape polyShape;
        
        
    float gap = 0;//.005f;
    polyShape.SetAsBox((Box.size.width / 2.0 / PIXELS_PER_METER)+gap, (Box.size.height / 2.0 / PIXELS_PER_METER)+gap);
    fixtureDef.shape = &polyShape;
    
    fixtureDef.density = DENSITY;
    fixtureDef.friction = FRICTION;
    fixtureDef.restitution = RESTITUTION;
    fixtureDef.isSensor = 0;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData((__bridge void*)Box);
    
//    SKSpriteNode *test = (__bridge SKSpriteNode *)body->GetUserData();
    
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
    [_boxes addObject:Box];
#endif
    
    [self addChild:Box];
    
}


#ifdef BOX2D
//- (void)updatePhysicsWithDeltaT:(double)deltaT Accumulator:(double)accumulator TimeStep:(double)timeStep World:(b2World *)world{
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
//                if(b == NULL){
//                    return;
//                }
                
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
        
//        for (b2Body* c = world->GetBodyList(); c; c = c->GetNext()) {
//            SKSpriteNode *box = (__bridge SKSpriteNode*)c->GetUserData();
//            [box removeFromParent];
//            c->GetWorld()->DestroyBody(c);
//        }
        
        accumulator -= timeStep;
    }
    
    
    // interpolate remainder of update
    const double alpha = accumulator / timeStep;
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
//        if(b == NULL){
//            return;
//        }
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

- (void)destroyBodyFromWorld
{
    for(NSInteger i=_bodyToRemove.count-1;i>=0;i--){
        NSValue *bodyValue = [_bodyToRemove objectAtIndex:i];
        b2Body *bodyToRemove = (b2Body *)[bodyValue pointerValue];
        if(bodyToRemove){
//            if(bodyValue){
//                NSLog(@"bodyvalue is still there");
//            }
//            if([NSValue valueWithPointer:bodyToRemove]){
//                NSLog(@"body valule 2 is still there");
//            }
            SKSpriteNode *box = (__bridge SKSpriteNode*)bodyToRemove->GetUserData();
            [box removeFromParent];
            bodyToRemove->GetWorld()->DestroyBody(bodyToRemove);
            
            [_bodyToRemove removeObject:bodyValue];
        }
    }
}

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
        updatePhysics(deltaT, _accumulator, _timeStep, _world);
        [self destroyBodyFromWorld];
//        [self updatePhysicsWithDeltaT:deltaT Accumulator:_accumulator TimeStep:_timeStep World:_world];
        
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
//    SKNode *nodeA = contact.bodyA.node;
//    SKNode *nodeB = contact.bodyB.node;
//    
//    if(nodeA && nodeB){
//        if([nodeA.name isEqualToString:@"Box"] && [nodeB.name isEqualToString:@"Box"]){
//            [self combineBoxA:nodeA BoxB:nodeB];
//        }
//    }
//    NSLog(@"contact");
}

- (void)combineBoxA:(SKNode *)boxA BoxB:(SKNode *)boxB
{
    float nodeASurface = boxA.frame.size.width * boxA.frame.size.height;//CGSizeMake(nodeA.xScale * nodeA.frame.size.width, nodeA.yScale * nodeA.frame.size.height);
    float nodeBSurface = boxB.frame.size.width * boxB.frame.size.height;//CGSizeMake(nodeB.xScale * nodeB.frame.size.width, nodeB.yScale * nodeB.frame.size.height);
    float nodeCombinedSurface = sqrtf(nodeASurface + nodeBSurface);
    CGSize newSize = CGSizeMake(nodeCombinedSurface, nodeCombinedSurface);// CGSizeMake(nodeASize.width + nodeBSize.width, nodeASize.height + nodeBSize.height);
    
    //            NSLog(@"scale nodeA = %f/%f  nodeB = %f/%f", nodeA.xScale,nodeA.yScale,nodeB.xScale,nodeB.yScale);
    //            NSLog(@"size nodeA = %f/%f  nodeB = %f/%f", nodeA.frame.size.width,nodeA.frame.size.height,nodeB.frame.size.width,nodeB.frame.size.height);
    //            NSLog(@"new size = %@", NSStringFromCGSize(newSize));
    //            NSLog(@"-----");
    
    
    CGPoint newPos;
    //            if(nodeA.position.y < nodeB.position.y){
    if(nodeASurface > nodeBSurface){
        newPos = boxA.position;
    } else {
        newPos = boxB.position;
    }
    
    [self addBoxAtX:newPos.x Y:newPos.y Size:newSize];
    
#ifdef Box2D

#else
    [boxA removeFromParent];
    [boxB removeFromParent];

    [_boxes removeObject:boxA];
    [_boxes removeObject:boxB];
#endif
}

- (void)box2DCombineBodyA:(b2Body *)bodyA BodyB:(b2Body *)bodyB
{
    SKSpriteNode *boxA = (__bridge SKSpriteNode*)bodyA->GetUserData();
    SKSpriteNode *boxB = (__bridge SKSpriteNode*)bodyB->GetUserData();
    
    if(![boxA.name isEqualToString:@"Box"] || ![boxB.name isEqualToString:@"Box"])
        return;
    
    if([_bodyToRemove containsObject:[NSValue valueWithPointer:bodyA]])
        return;
    
    if([_bodyToRemove containsObject:[NSValue valueWithPointer:bodyB]])
        return;

    
    float nodeASurface = boxA.frame.size.width * boxA.frame.size.height;//CGSizeMake(nodeA.xScale * nodeA.frame.size.width, nodeA.yScale * nodeA.frame.size.height);
    float nodeBSurface = boxB.frame.size.width * boxB.frame.size.height;//CGSizeMake(nodeB.xScale * nodeB.frame.size.width, nodeB.yScale * nodeB.frame.size.height);
    float nodeCombinedSurface = sqrtf(nodeASurface + nodeBSurface);
    CGSize newSize = CGSizeMake(nodeCombinedSurface, nodeCombinedSurface);// CGSizeMake(nodeASize.width + nodeBSize.width, nodeASize.height + nodeBSize.height);
    
    //            NSLog(@"scale nodeA = %f/%f  nodeB = %f/%f", nodeA.xScale,nodeA.yScale,nodeB.xScale,nodeB.yScale);
    //            NSLog(@"size nodeA = %f/%f  nodeB = %f/%f", nodeA.frame.size.width,nodeA.frame.size.height,nodeB.frame.size.width,nodeB.frame.size.height);
    //            NSLog(@"new size = %@", NSStringFromCGSize(newSize));
    //            NSLog(@"-----");
    
    
    CGPoint newPos;
    //            if(nodeA.position.y < nodeB.position.y){
    NSLog(@"nodeA y = %f  nodeB y = %f",nodeASurface,nodeBSurface);
    if(nodeASurface > nodeBSurface){
        newPos = boxA.position;
    } else {
        newPos = boxB.position;
    }
    
    [self addBoxAtX:newPos.x Y:newPos.y Size:newSize];
    
//    bodyA->GetWorld()->DestroyBody(bodyA);
//    bodyB->GetWorld()->DestroyBody(bodyB);
//
    NSValue *bodyAValue = [NSValue valueWithPointer:bodyA];
    NSValue *bodyBValue = [NSValue valueWithPointer:bodyB];
//    if(![_bodyToRemove containsObject:bodyAValue]){
        [_bodyToRemove addObject:bodyAValue];
//    }
//    if(![_bodyToRemove containsObject:bodyBValue]){
        [_bodyToRemove addObject:bodyBValue];
//    }
//    [self destroyBodyFromWorld];
}

//- (BOOL)checkIfBoxIsSleeping:(SKSpriteNode *)box
//{
//    return box
//}

//- (BOOL)getTouchingBodyForBody:(b2Body*)body
//{
//    BOOL test = b2TestOverlap(const b2Shape* body,const b2Shape* body);
//    return test;
//}

- (void)onTickForBox2D:(NSTimer *)timer
{
//    NSLog(@"tick");
    
//    b2Body *test = world->GetBodyList();
    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext()) {
        if(!b->IsAwake()){
            for (b2ContactEdge* edge = b->GetContactList(); edge; edge = edge->next) {
                if (edge->contact->IsTouching()) {
                    b2Body* bodyA = edge->contact->GetFixtureA()->GetBody();
                    b2Body* bodyB = edge->contact->GetFixtureB()->GetBody();
                    if(bodyA != bodyB && bodyA!=NULL && bodyB!=NULL){
//                        SKSpriteNode *boxA = (__bridge SKSpriteNode*)bodyA->GetUserData();
//                        SKSpriteNode *boxB = (__bridge SKSpriteNode*)bodyB->GetUserData();
//                        NSLog(@"box a = %@  b = %@",boxA.name,boxB.name);
//                        if([boxA.name isEqualToString:@"Box"] && [boxB.name isEqualToString:@"Box"]){
//                            [self combineBoxA:boxA BoxB:boxB];
                            [self box2DCombineBodyA:bodyA BodyB:bodyB];
//                            return;
//                        }
                    }
                }
            }
        
            
//            NSLog(@"sleeping!");
        }
    }
//    for(var body:b2Body = world.GetBodyList(); body; body = body.GetNext())
//    {
//        list.text+="\n";
//        list.text+=(body +" " + body.GetUserData());
//    }
}

- (SKSpriteNode *)getNearestTouchingNode:(SKSpriteNode *)targetNode
{
    NSLog(@"check touch");
    for(SKSpriteNode *node in _boxes){
        if(targetNode != node)
        {
            if([targetNode intersectsNode:node]){
                return node;
            }
        }
    }
    return nil;
}

- (void)onTickForSK:(NSTimer *)timer
{
//    NSLog(@"tick");s
    for(SKSpriteNode *node in _boxes){
        if(node.physicsBody.isResting){
            SKSpriteNode *nearestTouchingNode = [self getNearestTouchingNode:node];
            if(nearestTouchingNode){
                [self combineBoxA:node BoxB:nearestTouchingNode];
                break;
            }
        }
    }
}

@end
