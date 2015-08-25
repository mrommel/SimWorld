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
    
    RELight *light = [REDirectionalLight light];
    [self.world addLight:light];
    
    // Tree
    self.treeNode = [[TreeNode alloc] initWithType:TREE_TYPE_GARDENWOOD];
    [self.world addChild:self.treeNode];
    
    [self addZoomButtons];
}

- (void)addZoomButtons
{
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    __weak typeof(self) weakSelf = self;
    
    UIBlockButton *zoomInButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [zoomInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [zoomInButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [zoomInButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               [weakSelf zoomIn];
                               NSLog(@"Zoom: + => %@", weakSelf.zoomLevel);
                           }];
    [zoomInButton setTitle:@"+" forState:UIControlStateNormal];
    zoomInButton.frame = CGRectMake(BU, 48, BU2, BU2);
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
    zoomOutButton.frame = CGRectMake(BU, 76, BU2, BU2);
    [glView_ addSubview:zoomOutButton];
    
    UIBlockButton *centerButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [centerButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [centerButton handleControlEvent:UIControlEventTouchUpInside
                           withBlock:^{
                               NSLog(@"Center");
                               [weakSelf center];
                           }];
    [centerButton setTitle:@"x" forState:UIControlStateNormal];
    centerButton.frame = CGRectMake(BU, 104, BU2, BU2);
    [glView_ addSubview:centerButton];
}

@end
