//
//  BBBallPusherZone.m
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/10.
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import "BBBallPusherZone.h"

@implementation BBBallPusherZone

CGPoint _touchStartPoint;
CGPoint _touchEndPoint;
SKNode *_ballPusher;
CGFloat currentZRotationDegree = 0.0f;
BOOL isTouchMoving;

- (void)setPusher:(SKNode *)pusher{
    _ballPusher = pusher;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchStartPoint = [[touches anyObject]locationInNode:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouchMoving = YES;
    CGFloat deltaY = [[touches anyObject]locationInNode:self].y - _touchStartPoint.y;
    CGFloat deltaDegree = ((deltaY / self.size.height) * 180);
    CGFloat rotateDegree =  (currentZRotationDegree + deltaDegree);
    int MAX_ANGLE = 60;
    if (MAX_ANGLE < rotateDegree) {
        rotateDegree = MAX_ANGLE;
    }
    if (rotateDegree < -MAX_ANGLE) {
        rotateDegree = -MAX_ANGLE;
    }
    CGFloat dRad = rotateDegree * (M_PI / 180);
    _ballPusher.zRotation = dRad;
    currentZRotationDegree = rotateDegree;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _touchEndPoint = [[touches anyObject]locationInNode:self];
    if (isTouchMoving == NO) {
        if (self.delegate) {
            [self.delegate pusherZoneTapEnded:_ballPusher.zRotation];
        }        
    }
    isTouchMoving = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    _touchStartPoint = CGPointZero;
    _touchEndPoint = CGPointZero;
}

@end
