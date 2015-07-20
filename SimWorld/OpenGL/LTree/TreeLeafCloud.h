//
//  TreeLeafCloud.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mesh.h"
#import "CC3GLMatrix+Extension.h"

@class TreeSkeleton;

@interface TreeLeafCloud : Mesh

@property (atomic) CC3BoundingSphere boundingSphere;

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton;

@end
