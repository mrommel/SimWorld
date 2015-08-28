//
//  TestViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TestViewController.h"

#import "TreeNode.h"
#import "UIBlockButton.h"
#import "UIConstants.h"

@interface TestViewController() {
    
}

@property (nonatomic, retain) TreeNode *treeNode;

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.scale = 50;
    
    RELight *light = [REDirectionalLight light];
    [self.world addLight:light];
    
    // Tree
    self.treeNode = [[TreeNode alloc] initWithType:TREE_TYPE_RUG];
    self.treeNode.showTrunk = YES;
    self.treeNode.showLeaves = YES;
    [self.world addChild:self.treeNode];
    
    [self addZoomButtons];
}

- (void)addZoomButtons
{
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    __weak typeof(self) weakSelf = self;
    
    UIBlockButton *showTrunkButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [showTrunkButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [showTrunkButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [showTrunkButton handleControlEvent:UIControlEventTouchUpInside
                              withBlock:^{
                                  weakSelf.treeNode.showTrunk = !weakSelf.treeNode.showTrunk;
                                  NSLog(@"Show Trunk: %d", weakSelf.treeNode.showTrunk);
                              }];
    [showTrunkButton setTitle:@"T" forState:UIControlStateNormal];
    showTrunkButton.frame = CGRectMake(BU, BU, BU2, BU2);
    [glView_ addSubview:showTrunkButton];
    
    UIBlockButton *showLeavesButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [showLeavesButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [showLeavesButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [showLeavesButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               weakSelf.treeNode.showLeaves = !weakSelf.treeNode.showLeaves;
                               NSLog(@"Show Leaves: %d", weakSelf.treeNode.showLeaves);
                           }];
    [showLeavesButton setTitle:@"L" forState:UIControlStateNormal];
    showLeavesButton.frame = CGRectMake(BU + BU2 + BU, BU, BU2, BU2);
    [glView_ addSubview:showLeavesButton];
    
    UIBlockButton *zoomInButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [zoomInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [zoomInButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [zoomInButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               [weakSelf zoomIn];
                               NSLog(@"Zoom: + => %@", weakSelf.zoomLevel);
                           }];
    [zoomInButton setTitle:@"+" forState:UIControlStateNormal];
    zoomInButton.frame = CGRectMake(BU + BU2 + BU + BU2 + BU, BU, BU2, BU2);
    [glView_ addSubview:zoomInButton];
    
    UIBlockButton *zoomOutButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [zoomOutButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [zoomOutButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [zoomOutButton handleControlEvent:UIControlEventTouchUpInside
                            withBlock:^{
                                [weakSelf zoomOut];
                                NSLog(@"Zoom: - => %@", weakSelf.zoomLevel);
                            }];
    [zoomOutButton setTitle:@"-" forState:UIControlStateNormal];
    zoomOutButton.frame = CGRectMake(BU + BU2 + BU + BU2 + BU + BU2 + BU, BU, BU2, BU2);
    [glView_ addSubview:zoomOutButton];
    
    UIBlockButton *centerButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [centerButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [centerButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               NSLog(@"Center");
                               [weakSelf center];
                           }];
    [centerButton setTitle:@"C" forState:UIControlStateNormal];
    centerButton.frame = CGRectMake(BU + BU2 + BU + BU2 + BU + BU2 + BU + BU2 + BU, BU, BU2, BU2);
    [glView_ addSubview:centerButton];
    
    UIBlockButton *treeButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [treeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [treeButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [treeButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               NSLog(@"Next Tree");
                               [weakSelf nextTree];
                           }];
    [treeButton setTitle:@"TR" forState:UIControlStateNormal];
    treeButton.frame = CGRectMake(BU + BU2 + BU + BU2 + BU + BU2 + BU + BU2 + BU + BU2 + BU, BU, BU2 + BU, BU2);
    [glView_ addSubview:treeButton];
}

- (void)nextTree
{
    // remove old tree
    BOOL showTrunk = self.treeNode.showTrunk;
    BOOL showLeaves = self.treeNode.showLeaves;
    [self.world removeChild:self.treeNode];
    
    // Tree
    int treeIndex = RandomUIntBelow(TREE_TYPES);
    self.treeNode = [[TreeNode alloc] initWithType:treeIndex];
    self.treeNode.showTrunk = showTrunk;
    self.treeNode.showLeaves = showLeaves;
    [self.world addChild:self.treeNode];
}

@end
