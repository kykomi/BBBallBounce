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

- (void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

- (void)createContent{
    self.backgroundColor = [SKColor blackColor];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self addChild:[self ballPusher]];
    [self addChild:[self replayLabel]];
}

- (SKLabelNode *)replayLabel{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.text = @"replay";
    label.name = @"replay";
    label.position =  toSpriteKitPointFromUIKitPoint(CGPointMake(self.frame.size.width - label.frame.size.width/2,
                                                                40),
                                                     self.view);
    label.color = [SKColor whiteColor];
    label.fontSize = 18;
    label.zPosition = 1.0;
    return label;
}

- (SKSpriteNode *)ballPusher{
    SKSpriteNode *ballPusher = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(40, 20)];
    ballPusher.name = @"pusher";
    ballPusher.physicsBody.dynamic = NO;
    ballPusher.physicsBody.affectedByGravity = NO;
    ballPusher.position = toSpriteKitPointFromUIKitPoint(CGPointMake(40,40), self.view);
    return ballPusher;
}

- (void)throwBall{
//    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(10, 10)];
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
    ball.name = @"ball";
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5.0];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.restitution = 0.9;
    ball.physicsBody.velocity = CGVectorMake(200, 200);

    ball.position =  toSpriteKitPointFromUIKitPoint(CGPointMake(60, 40),self.view);
    [self addChild:ball];
}

- (void)addWall{
    CGPoint fromPoint = _touchStartPoint;
    CGPoint toPoint = _touchEndPoint;

    SKSpriteNode *wall = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor]
                                                       size:wallSizeFromTouches(fromPoint,toPoint)];
    wall.name = @"wall";
    wall.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:wall.frame];
    wall.physicsBody.affectedByGravity = NO;
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
            
            [self throwBall];
            break;
        case BBSwipe:
            [self addWall];
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


#pragma mark - util
static inline CGPoint toSpriteKitPointFromUIKitPoint(CGPoint point,SKView *baseView){
    return CGPointMake(point.x, baseView.frame.size.height - point.y);
}

static inline CGSize wallSizeFromTouches(CGPoint start ,CGPoint end){
    return CGSizeMake(sqrt(pow(start.x - end.x,2) + pow(start.y - end.y,2)),
                      2);
}

static inline CGPoint midPoint(CGPoint a, CGPoint b){
    return CGPointMake((a.x + b.x)/2 , (a.y + b.y)/2);
}



@end
