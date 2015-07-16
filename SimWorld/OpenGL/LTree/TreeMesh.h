//
//  TreeMesh.h
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mesh.h"

@class TreeSkeleton;

@interface TreeMesh : Mesh

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton;
- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton andNumberOfRadialSegments:(int)numberOfRadialSegments;

- (void)addCircleVerticesWithTransform:(CC3GLMatrix*)transform
                             andRadius:(float)radius andSegments:(int)segments
                           andTextureY:(float)textureY
                      andTextureStartX:(float)textureStartX
                       andTextureSpanX:(float)textureSpanX
                           andVertices:(NSMutableArray*)vertices
                              andBone1:(int)bone1
                              andBone2:(int)bone2;

@end
