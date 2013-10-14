//
//  BBGameScene.h
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/06.
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BBBallPusherZone.h"

@interface BBGameScene : SKScene<SKPhysicsContactDelegate,BBBallPusherDelegate>
{
    CGPoint _touchStartPoint,_touchEndPoint;
}

typedef NS_ENUM(NSUInteger, BBTapType){
    BBTap,
    BBSwipe,
    BBElse
};

@end
