//
//  BBGameScene.m
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/06.
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import "BBGameScene.h"

@interface BBGameScene()
@property BOOL contentCreated;
@end

@implementation BBGameScene

static const uint32_t ballCategory     =  0x1 << 0;
static const uint32_t wallCategory        =  0x1 << 1;
static const uint32_t shapeCategory    =  0x1 << 2;

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

- (void)createContent{
    self.backgroundColor = [SKColor blackColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect: self.frame];
    self.scaleMode = SKSceneScaleModeAspectFit;
    //TODO: Node#addChildがうまくいかない・・・
    //TODO: 回転は
    BBBallPusherZone *ballPusherZone = [self ballPusherZone];
    SKNode *ballPusher = [self ballPusher];
    [ballPusherZone setPusher:ballPusher];
    ballPusherZone.delegate = self;
    [self addChild:ballPusherZone];
    [self addChild:ballPusher];
    [self addChild:[self replayLabel]];
    self.physicsWorld.contactDelegate = self;
}

- (SKLabelNode *)replayLabel{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.text = @"replay";
    label.name = @"replay";
    label.position = CGPointMake(self.view.bounds.size.width - label.frame.size.width/2,
                                 self.view.bounds.size.height - label.frame.size.height/2);
    label.color = [SKColor whiteColor];
    label.fontSize = 18;
    label.zPosition = 1.0;
    return label;
}

- (BBBallPusherZone *)ballPusherZone{
    BBBallPusherZone *zone = [[BBBallPusherZone alloc]initWithColor:[SKColor blueColor] size:CGSizeMake(44, self.view.bounds.size.height)];
    zone.position  = CGPointMake(zone.size.width / 2, self.view.bounds.size.height / 2);
    zone.userInteractionEnabled = YES;
    return zone;
}

- (SKSpriteNode *)ballPusher{
    SKSpriteNode *ballPusher = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(40, 20)];
    ballPusher.name = @"pusher";
    ballPusher.physicsBody.dynamic = NO;
    ballPusher.physicsBody.affectedByGravity = NO;
    ballPusher.position = CGPointMake(ballPusher.frame.size.width/2, 160);
    ballPusher.anchorPoint = CGPointMake(0, 0.5);
    return ballPusher;
}

- (void)throwBallAtAngle:(CGFloat)angle{
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
    ball.name = @"ball";
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5.0];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.restitution = 0.9;
    CGFloat tanOfAngle = tan(angle);
    CGFloat baseVerocity = 200;
    ball.physicsBody.velocity = CGVectorMake(1 * baseVerocity,tanOfAngle * baseVerocity);
    [self enumerateChildNodesWithName:@"pusher" usingBlock:^(SKNode *node,BOOL *stop){
        ball.position =  node.position;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        CGPoint rotatedPointAtOrigin = CGPointApplyAffineTransform(CGPointMake(node.frame.size.width,0), transform);
        CGAffineTransform transformToPusher = CGAffineTransformMakeTranslation(node.position.x, node.position.y);
        CGPoint rotated = CGPointApplyAffineTransform(rotatedPointAtOrigin, transformToPusher);
        ball.position = rotated;
        ball.physicsBody.categoryBitMask = ballCategory;
        ball.physicsBody.collisionBitMask = wallCategory | shapeCategory | ballCategory;
        ball.physicsBody.contactTestBitMask = wallCategory;
        [self addChild:ball];
    }];

}

- (void)throwShape{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat offsetY = 430;
    CGPathMoveToPoint(path, NULL, 28 , 452 - offsetY);
    CGPathAddLineToPoint(path, NULL, 38 , 434 - offsetY);
    CGPathAddLineToPoint(path, NULL, 93 , 433 - offsetY);
    CGPathAddLineToPoint(path, NULL, 93 , 468 - offsetY);
    CGPathCloseSubpath(path);
    SKShapeNode *s = [[SKShapeNode alloc]init];
    s.path = path;
    s.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    s.physicsBody.dynamic = YES;
    s.physicsBody.mass = 100;
    s.physicsBody.affectedByGravity = YES;
    s.physicsBody.restitution = 0.4;
    s.physicsBody.categoryBitMask = shapeCategory;
    s.physicsBody.collisionBitMask = ballCategory | shapeCategory | wallCategory;
    s.position =  toSpriteKitPointFromUIKitPoint(CGPointMake(100, 40),self.view);
    [self addChild:s];
}

- (void)addWall{
    CGPoint fromPoint = _touchStartPoint;
    CGPoint toPoint = _touchEndPoint;

    SKSpriteNode *wall = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor]
                                                       size:wallSizeFromTouches(fromPoint,toPoint)];
    wall.name = @"wall";
    wall.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:wall.frame];
    wall.physicsBody.affectedByGravity = NO;
    wall.physicsBody.categoryBitMask = wallCategory;
    wall.physicsBody.collisionBitMask = ballCategory | shapeCategory;
    wall.position = midPoint(fromPoint, toPoint);
    [self addChild:wall];
    
    //はじめから斜めにRectをどう置くかわからないのでアニメーションして回転
    double rad = atan((fromPoint.y - toPoint.y)/(fromPoint.x - toPoint.x));
    SKAction *rotate = [SKAction sequence:@[
                                            [SKAction rotateByAngle:rad duration:0],
                                            [SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0]
                                            ]
                        ];

    [wall runAction:rotate];
}


#pragma mark - manage touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _touchStartPoint = [[touches anyObject]locationInNode:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _touchEndPoint = [[touches anyObject]locationInNode:self];
    switch ([self gestureType:_touchStartPoint andEnd:_touchEndPoint]) {
        case BBTap:
            if ([[self nodeAtPoint:_touchEndPoint].name isEqualToString:@"replay"]) {
                [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node,BOOL *stop){
                    [node removeFromParent];
                }];
                [self enumerateChildNodesWithName:@"wall" usingBlock:^(SKNode *node,BOOL *stop){
                    [node removeFromParent];
                }];
                return;
            }
            
            if ([[self nodeAtPoint:_touchStartPoint].name isEqualToString:@"wall"]) {
                [[self nodeAtPoint:_touchStartPoint] removeFromParent];
            }
            break;
        case BBSwipe:
            break;
        default:
            break;
    }
}

- (BBTapType)gestureType:(CGPoint) start andEnd:(CGPoint) end{
    if (((start.x == end.x) && (start.y == end.y)) || ((abs(start.x - end.x) < 20) && (abs(start.y - end.y) < 20))) {
        return BBTap;
    }else{
        if ((abs(start.x - end.x) < 20) && (abs(start.y - end.y) < 20)) {
            return BBElse;
        }
        return BBSwipe;
    }
}

#pragma mark - collision delegate
- (void)didBeginContact:(SKPhysicsContact *)contact{
//    NSLog(@"col");
}

#pragma mark - BBBallPusherZoneDelegate
- (void)pusherZoneTapEnded:(CGFloat)pusherAngle{
    [self throwBallAtAngle:pusherAngle];
}


#pragma mark - util
static inline CGPoint toSpriteKitPointFromUIKitPoint(CGPoint point,SKView *baseView){
    return CGPointMake(point.x, baseView.bounds.size.height - point.y);
}

static inline CGSize wallSizeFromTouches(CGPoint start ,CGPoint end){
    return CGSizeMake(sqrt(pow(start.x - end.x,2) + pow(start.y - end.y,2)),
                      6);
}

static inline CGPoint midPoint(CGPoint a, CGPoint b){
    return CGPointMake((a.x + b.x)/2 , (a.y + b.y)/2);
}



@end
