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
#define BIG_BOX_WIDTH (100)
#define SMALL_BOX_HEIGHT (SMALL_BOX_WIDTH / 1)
#define BIG_BOX_HEIGHT (BIG_BOX_WIDTH / 1)
#define ANGULAR_VELOCITY (0)
#define ANGULAR_DAMPING (0)
#define LINEAR_DAMPING (0)
#define DENSITY (1.0)
#define FRICTION (1.0)
#define RESTITUTION (0)
#define GRAVITY (-4)
#define EPSILON (.05)
#define RANDOM_SIZE
#define GRID_LAYOUT_FOR_CREATION

#define GROUP_CREATION_DELAY (10)
//#define CREATION_IDLE_TICK_DELAY (180)
//#define CREATION_IDLE_TICK_MODIF (20)
//#define MANUAL_COMBINE_TICK_MODIF (30)

#define radiansToDegrees(x) (180/M_PI)*x

float boxWidth = BIG_BOX_WIDTH;
float boxHeight = BIG_BOX_HEIGHT;

@implementation MyScene {
    CGSize _screenDimen;
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
    int _tick;
//    int _nextTickForManualCombine;
    int _nextTickForGroupCreation;
    BOOL _userIsTouching;
    CGPoint _currentUserTouchPos;
//    int _creationIdleTick;
    
    NSMutableDictionary *_randomXDict;
    NSMutableDictionary *_randomYDict;
    CMMotionManager *_motionManager;
    CMAttitude *_referenceAttitude;
    
    NSArray *_boxColors;
    float _currentAggBoxHeight;
}

- (id) initWithSize:(CGSize)size MotionManager:(CMMotionManager *)motionManager
{
    self = [self initWithSize:size];
    return self;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        _motionManager = [[CMMotionManager alloc] init];
        
        // Turn on the appropriate type of data
        _motionManager.accelerometerUpdateInterval = 0.01;
        _motionManager.deviceMotionUpdateInterval = 0.01;
        
        [_motionManager startDeviceMotionUpdates];
        
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
//        _manualCombineTickModif = 10;
//        _nextTickForManualCombine = MANUAL_COMBINE_TICK_MODIF;
        _screenDimen = [[UIScreen mainScreen] bounds].size;
        
        _randomXDict = [[NSMutableDictionary alloc] init];
        _randomYDict = [[NSMutableDictionary alloc] init];
        
        _boxColors = [[NSArray alloc] initWithObjects:[UIColor whiteColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor],[UIColor purpleColor],[UIColor magentaColor],[UIColor blueColor],[UIColor brownColor],[UIColor greenColor],[UIColor lightGrayColor], nil];
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
        [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(onTickForBox2D:) userInfo:nil repeats:YES];
        
#else
        NSLog(@"SKPhysics Elastic - %d boxes", NUM_BOXES);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, g);
        self.physicsWorld.contactDelegate = self;
        
        _boxes = [[NSMutableArray alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(onTickForSK:) userInfo:nil repeats:YES];
#endif
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        [self addBoxes];
        
    }
    return self;
}

-(void)addBoxes {
//    CGRect stageRect = [[UIScreen mainScreen] bounds];
#ifdef GRID_LAYOUT_FOR_CREATION
    float xStart = boxWidth - 3;
    float yStart = self.size.height-2*boxHeight;
    
    int rowSize = self.size.width / (boxWidth + 5);
    
    for(int i = 0;i<NUM_BOXES;i++) {
        float x = (i % rowSize) * (boxWidth + 5) + xStart;
        float y = yStart - (i / rowSize) * (boxHeight * 1.5);
        [self addBoxAtX:x Y:y Size:CGSizeMake(boxWidth, boxHeight) CombinedMode:NO];
    }
#else
    for(int i = 0;i<NUM_BOXES;i++) {
        [self addBoxAtX:arc4random_uniform(stageRect.size.width) Y:arc4random_uniform(_screenDimen.size.height*.3) + _screenDimen.size.height*.5 Size:CGSizeMake(boxWidth, boxHeight) CombinedMode:NO];
    }
#endif
}


- (void)addBoxAtX:(float )x Y:(float)y Size:(CGSize)size CombinedMode:(BOOL)combinedMode {
    
    // MAKE SURE NEW SIZE DOESNT EXCEED SCREEN DIMENSION
    
    if(size.width > _screenDimen.width){
        float totalSurface = size.width*size.height;
        float newHeight = totalSurface/_screenDimen.width;
        size = CGSizeMake(_screenDimen.width, newHeight);
    }
    if(size.width >= _screenDimen.width && size.height >= _screenDimen.height) {
        size = _screenDimen;
    }
    
//    NSInteger randomIndex = arc4random()%_boxColors.count;
//    UIColor *randomColor =  [_boxColors objectAtIndex:randomIndex];
    SKSpriteNode *Box = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:size];
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
    bodyDef.fixedRotation = true;
    
    b2Body* body = _world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    b2PolygonShape polyShape;
    
    polyShape.SetAsBox((Box.size.width / 2.0 / PIXELS_PER_METER), (Box.size.height / 2.0 / PIXELS_PER_METER));
    fixtureDef.shape = &polyShape;
    
    
    fixtureDef.density = DENSITY;
    fixtureDef.friction = FRICTION;
    fixtureDef.restitution = RESTITUTION;
    fixtureDef.isSensor = 0;
    
    body->CreateFixture(&fixtureDef);
    
    body->SetUserData((__bridge void*)Box);
    
    body->SetAngularVelocity(ANGULAR_VELOCITY);
    body->SetAngularDamping(ANGULAR_DAMPING);
    body->SetLinearDamping(LINEAR_DAMPING);
    if(!combinedMode) {
        float randomX = (((int)(arc4random()%4)-1))*.001;
        float randomY = (((int)(arc4random()%2)))*.001;
        body->ApplyLinearImpulse(b2Vec2(randomX,randomY), body->GetWorldPoint(b2Vec2(1,1)));

    }
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

- (void)testTrackRandomForce:(CGPoint)pos
{
    NSNumber *randomXNumber = [NSNumber numberWithFloat:pos.x];
    NSNumber *randomYNumber = [NSNumber numberWithFloat:pos.y];
    
    NSNumber *xNumberCounter = [_randomXDict objectForKey:randomXNumber];
    NSNumber *YNumberCounter = [_randomYDict objectForKey:randomYNumber];
    
    if(!xNumberCounter){
        xNumberCounter = [NSNumber numberWithInt:1];
        [_randomXDict setObject:xNumberCounter forKey:randomXNumber];
    } else {
        xNumberCounter = [NSNumber numberWithInt:[xNumberCounter intValue]+1];
        [_randomXDict setObject:xNumberCounter forKey:randomXNumber];
    }
    
    if(!YNumberCounter){
        YNumberCounter = [NSNumber numberWithInt:1];
        [_randomYDict setObject:YNumberCounter forKey:randomYNumber];
    } else {
        YNumberCounter = [NSNumber numberWithInt:[YNumberCounter intValue]+1];
        [_randomYDict setObject:YNumberCounter forKey:randomYNumber];
    }
    
    NSLog(@"|||||||||||||||||");
    for(NSNumber *number in _randomXDict){
        NSNumber *countNumber = [_randomXDict objectForKey:number];
        NSLog(@"numX = %f  count = %i",[number floatValue], [countNumber intValue]);
    }
    NSLog(@"-----------");
    for(NSNumber *number in _randomYDict){
        NSNumber *countNumber = [_randomYDict objectForKey:number];
        NSLog(@"numY = %f  count = %i",[number floatValue], [countNumber intValue]);
    }
    NSLog(@"|||||||||||||||||");
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
            SKSpriteNode *box = (__bridge SKSpriteNode*)bodyToRemove->GetUserData();
            [box removeFromParent];
            bodyToRemove->GetWorld()->DestroyBody(bodyToRemove);
            
            [_bodyToRemove removeObject:bodyValue];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    _userIsTouching = YES;
    UITouch *touch = [touches anyObject];
    _currentUserTouchPos = [touch locationInNode:self];
//    _touchBoxCreateDelay = _tick;
    [self addBoxFromTouch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _currentUserTouchPos = [touch locationInNode:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _userIsTouching = NO;
//    [self addBoxFromTouch];
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
    float nodeASurface = boxA.frame.size.width * boxA.frame.size.height;
    float nodeBSurface = boxB.frame.size.width * boxB.frame.size.height;
    float nodeCombinedSurface = sqrtf(nodeASurface + nodeBSurface);
    CGSize newSize = CGSizeMake(nodeCombinedSurface, nodeCombinedSurface);
    
    CGPoint newPos;
    //            if(nodeA.position.y < nodeB.position.y){
    if(nodeASurface > nodeBSurface){
        newPos = boxA.position;
    } else {
        newPos = boxB.position;
    }
    
    [self addBoxAtX:newPos.x Y:newPos.y Size:newSize CombinedMode:YES];
    
#ifdef Box2D

#else
    [boxA removeFromParent];
    [boxB removeFromParent];

    [_boxes removeObject:boxA];
    [_boxes removeObject:boxB];
#endif
}

- (BOOL)box2DCombineBodyA:(b2Body *)bodyA BodyB:(b2Body *)bodyB
{
    SKSpriteNode *boxA = (__bridge SKSpriteNode*)bodyA->GetUserData();
    SKSpriteNode *boxB = (__bridge SKSpriteNode*)bodyB->GetUserData();
    
    if(![boxA.name isEqualToString:@"Box"] || ![boxB.name isEqualToString:@"Box"])
        return NO;
    
    if([_bodyToRemove containsObject:[NSValue valueWithPointer:bodyA]])
        return NO;
    
    if([_bodyToRemove containsObject:[NSValue valueWithPointer:bodyB]])
        return NO;

    
    float nodeASurface = boxA.frame.size.width * boxA.frame.size.height;
    float nodeBSurface = boxB.frame.size.width * boxB.frame.size.height;
    float nodeCombinedSurface = sqrtf(nodeASurface + nodeBSurface);
    CGSize newSize = CGSizeMake(nodeCombinedSurface, nodeCombinedSurface);
    
    CGPoint newPos;
    
    if(nodeASurface > nodeBSurface){
        
//        b2Vec2 pos = bodyA->GetWorldPoint(b2Vec2(0,0));
//        NSLog(@"pos %f, %f",pos.x,pos.y);
//        newPos = CGPointMake(pos.x*PIXELS_PER_METER, pos.y*PIXELS_PER_METER);// boxA.position;
//        newSize = CGSizeMake(boxA.frame.size.width, boxA.frame.size.height);
        newPos = boxA.position;
//        newPos = CGPointMake(boxA.position.x - (newSize.width*.5), boxA.position.y - (newSize.height*.5)) ;
    } else {
//        b2Vec2 pos = bodyB->GetWorldPoint(b2Vec2(0,0));
//        newPos = CGPointMake(pos.x, pos.y);// boxA.position;
        newPos = boxB.position;
        
//        newSize = CGSizeMake(boxB.frame.size.width, boxB.frame.size.height);
//        newPos = CGPointMake(boxB.position.x - (newSize.width*.5), boxB.position.y - (newSize.height*.5)) ;
    }
    
    [self addBoxAtX:newPos.x Y:newPos.y Size:newSize CombinedMode:YES];
    
    NSValue *bodyAValue = [NSValue valueWithPointer:bodyA];
    NSValue *bodyBValue = [NSValue valueWithPointer:bodyB];
        [_bodyToRemove addObject:bodyAValue];
        [_bodyToRemove addObject:bodyBValue];
    
    return YES;
}

- (void)onTickForBox2D:(NSTimer *)timer
{
    _tick++;

    
// FOR DOING TILT CONTROL AGITATION
//	CMRotationMatrix rotation;
//	CMAcceleration userAcceleration;
//    CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;
//	CMAttitude *attitude = deviceMotion.attitude;
//    if (_referenceAttitude != nil) {
//		[attitude multiplyByInverseOfAttitude:_referenceAttitude];
//	}
//	rotation = attitude.rotationMatrix;
//	userAcceleration = deviceMotion.userAcceleration;
    
    
//    CMQuaternion quat = _motionManager.deviceMotion.attitude.quaternion;
//    float myRoll = radiansToDegrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
//    float myPitch = radiansToDegrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
//    float myYaw = radiansToDegrees(2*(quat.x*quat.y + quat.w*quat.z));
//    
//    NSLog(@"roll= %f  pitch=%f  yaw=%f",myRoll, myPitch, myYaw);
    
//    if(_userIsTouching && _nextTickForGroupCreation < _tick){
//        _nextTickForGroupCreation = _tick + GROUP_CREATION_DELAY;
////        for(NSInteger k=0;k<3;k++){
//            [self addBoxFromTouch];
////        }
//    }

//    for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext()) {
//        if(!b->IsAwake() || _tick > _nextTickForManualCombine){
//            for (b2ContactEdge* edge = b->GetContactList(); edge; edge = edge->next) {
//                if (edge->contact->IsTouching()) {
//                    b2Body* bodyA = edge->contact->GetFixtureA()->GetBody();
//                    b2Body* bodyB = edge->contact->GetFixtureB()->GetBody();
//                    if(bodyA != bodyB && bodyA!=NULL && bodyB!=NULL){
//                        if([self box2DCombineBodyA:bodyA BodyB:bodyB]){
//                            if(_tick>_creationIdleTick){
//                                _nextTickForManualCombine = _tick + CREATION_IDLE_TICK_MODIF;
//                            } else {
//                                _nextTickForManualCombine = _tick + MANUAL_COMBINE_TICK_MODIF;
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    if(_tick > _nextTickForGroupCreation){
        _nextTickForGroupCreation = _tick + GROUP_CREATION_DELAY;
        [self addBoxGroups];
    }
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

- (void)addBoxFromTouch
{
//    _creationIdleTick = _tick + CREATION_IDLE_TICK_DELAY;
    float aggWidth = 0;
    while (aggWidth < _screenDimen.width) {
        CGSize size;
    #ifdef RANDOM_SIZE
        float newBoxWidth = arc4random_uniform(boxWidth*.8)+ (boxWidth*.2);
        size = CGSizeMake(newBoxWidth, newBoxWidth);
    #else
        size = CGSizeMake(boxWidth,boxHeight);
    #endif
        CGPoint newPos = CGPointMake(aggWidth + (size.width*.5), _currentUserTouchPos.y);
//        NSLog(@"pos %f",newPos.y);
        aggWidth += size.width;
        if(aggWidth < _screenDimen.width){
            [self addBoxAtX:newPos.x Y:newPos.y Size:size CombinedMode:NO];
        }
    }
}

- (void)addBoxGroups
{
    if(_currentAggBoxHeight >= (_screenDimen.height*.9))
        return;
 
//    NSLog(@"creating new box group");
    float highestHeight =0;
    float aggWidth = 0;
    float totalGroupWidth = 0;
    NSMutableArray *boxSizeArray = [[NSMutableArray alloc]init];
    while (aggWidth < _screenDimen.width) {
        CGSize size;
#ifdef RANDOM_SIZE
        float newBoxWidth = arc4random_uniform(boxWidth*.8)+ (boxWidth*.2);
        size = CGSizeMake(newBoxWidth, newBoxWidth);
#else
        size = CGSizeMake(boxWidth,boxHeight);
#endif
        
        aggWidth += size.width;
//        NSLog(@"agg width = %f",aggWidth);
        if(aggWidth < _screenDimen.width){
            [boxSizeArray addObject:[NSValue valueWithCGSize:size]];
            totalGroupWidth += size.width;
            
            if(highestHeight < size.height){
                highestHeight = size.height;
            }
        }
    }
    
    float lastEndPosX = 0;
    float gap = (_screenDimen.width - totalGroupWidth)/(boxSizeArray.count-1);
    for(NSInteger i=0;i<boxSizeArray.count;i++) {
        CGSize size = [[boxSizeArray objectAtIndex:i] CGSizeValue];
        
        float currentGap = (i!=0) ? gap : 0;
        CGPoint newPos = CGPointMake(lastEndPosX + (size.width*.5) + currentGap, 448);
        lastEndPosX = newPos.x + (size.width*.5);
//        NSLog(@"size = %@   pos = %@",NSStringFromCGSize(size),NSStringFromCGPoint(newPos));
        [self addBoxAtX:newPos.x Y:newPos.y Size:size CombinedMode:NO];
        
    }
    
    _currentAggBoxHeight += highestHeight;
}

@end
