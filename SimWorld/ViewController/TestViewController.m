//
//  TestViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController() {
    
}

@property (nonatomic, retain) TreeNode *treeNode;

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RELight *light = [REDirectionalLight light];
    [self.world addLight:light];
    
    // Tree
    [self.world addChild:self.treeNode];
}

@end
