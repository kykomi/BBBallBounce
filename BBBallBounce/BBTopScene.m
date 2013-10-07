//
//  BBTopScene.m
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/06. 
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import "BBTopScene.h"

@interface BBTopScene()
@property BOOL contentCreated;
@end

@implementation BBTopScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:[self titleNode]];
}

- (SKLabelNode *)titleNode
{
    SKLabelNode *title = [SKLabelNode labelNodeWithFontNamed:@"Chaldsuter"];
    title.name = @"title";
    title.text = @"Ball Bounce!";
    title.fontSize = 42;
    title.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    return title;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view presentScene:[[BBGameScene alloc]initWithSize:self.size]];
}

@end
