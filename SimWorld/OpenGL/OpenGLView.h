//
//  OpenGLView.h
//  SimWorld
//
//  Created by Michael Rommel on 04.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "HexagonMapMesh.h"
@class HexagonMap;

@interface OpenGLView : UIView<HexagonMapMeshDelegate> {
}

@property (nonatomic, retain) HexagonMap *map;

- (id)initWithMap:(HexagonMap *)map;
- (void)setupDisplayLink;
- (void)detachDisplayLink;

@end
