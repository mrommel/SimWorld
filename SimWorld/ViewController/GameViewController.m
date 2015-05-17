//
//  GameViewController.m
//  SimWorld
//
//  Created by Michael Rommel on 19.01.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "GameViewController.h"

#import "TeapotNode.h"
#import "HouseNode.h"
#import "HexagonMapNode.h"

#import "UIBlockButton.h"
#import "UIConstants.h"

#import <GLKit/GLKit.h>

@interface GameViewController () {
}

//@property (nonatomic, retain) TeapotNode *teapotNode;
@property (nonatomic, retain) HouseNode *houseNode;
@property (nonatomic, retain) HexagonMapNode *mapNode;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addZoomButtons];
    
    RELight *light = [REDirectionalLight light];
    [self.world addLight:light];
    
    // Map
    self.mapNode = [[HexagonMapNode alloc] initWithMap:self.map];
    [self.world addChild:self.mapNode];
    
    // Teapot
    //self.teapotNode = [[TeapotNode alloc] initWithDefaultMesh:[REMeshCache meshNamed:@"teapot.obj"]];
    //[self.teapotNode setSizeX:5];
    //[self.world addChild:self.teapotNode];
    
    // House
    self.houseNode = [[HouseNode alloc] init];
    [self.houseNode setPosition:CC3VectorMake(20, -1, 20)];
    [self.houseNode setSizeX:1];
    [self.houseNode setRotation:CC3VectorMake(180, 0, 0)];
    [self.world addChild:self.houseNode];
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
                            NSLog(@"Zoom: +");
                            [weakSelf zoomIn];
                        }];
    [zoomInButton setTitle:@"+" forState:UIControlStateNormal];
    zoomInButton.frame = CGRectMake(BU, 48, BU2, BU2);
    [glView_ addSubview:zoomInButton];
    
    UIBlockButton *zoomOutButton = [UIBlockButton buttonWithType:UIButtonTypeCustom];
    [zoomOutButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [zoomOutButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [zoomOutButton handleControlEvent:UIControlEventTouchUpInside
                            withBlock:^{
                                NSLog(@"Zoom: -");
                                [weakSelf zoomOut];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapNode = nil;
    //self.teapotNode = nil;
    self.houseNode = nil;
}

- (void)update:(float)dt
{
    static float angle = 0;
    
    angle += 0.4;
    //self.houseNode.rotationAngle = angle;
    //self.teapotNode.rotationAngle = angle;
}

@end
