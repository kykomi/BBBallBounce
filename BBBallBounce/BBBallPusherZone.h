//
//  BBBallPusherZone.h
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/10.
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol BBBallPusherDelegate <NSObject>
- (void)pusherZoneTapEnded:(CGFloat)pusherAngle;
@end

@interface BBBallPusherZone : SKSpriteNode

- (void)setPusher:(SKNode *)pusher;

@property(nonatomic,weak) id<BBBallPusherDelegate> delegate;

@end


