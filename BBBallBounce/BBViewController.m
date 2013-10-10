//
//  BBViewController.m
//  BBBallBounce
//
//  Created by 小宮山 司 on 2013/10/06.
//  Copyright (c) 2013年 Tsukasa K. All rights reserved.
//

#import "BBViewController.h"

@interface BBViewController ()

@end

@implementation BBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
    SKView *view = (SKView *)self.view;
    view.showsDrawCount = YES;
    view.showsNodeCount = YES;
    view.showsFPS = YES;
    BBTopScene *title = [[BBTopScene alloc]initWithSize:self.view.bounds.size];
    [view presentScene:title];
    NSLog(@"%@",NSStringFromCGSize(self.view.bounds.size));

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
