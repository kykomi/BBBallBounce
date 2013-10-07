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
	// Do any additional setup after loading the view, typically from a nib.
    SKView *view = (SKView *)self.view;
    view.showsDrawCount = YES;
    view.showsNodeCount = YES;
    view.showsFPS = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    BBTopScene *title = [[BBTopScene alloc]initWithSize:self.view.frame.size];
    SKView *view = (SKView *)self.view;
    [view presentScene:title];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
