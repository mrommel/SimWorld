//
//  OpenGLViewController.h
//  SimWorld
//
//  Created by Michael Rommel on 04.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenGLView.h"
@class HexagonMap;

@interface _OpenGLViewController : UIViewController

@property (nonatomic, strong) OpenGLView *glView;
@property (nonatomic, retain) HexagonMap *map;

@end
