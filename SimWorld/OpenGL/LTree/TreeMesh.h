//
//  TreeMesh.h
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TreeVertex.h"
#import "Mesh.h"

@class TreeSkeleton;

@interface TreeMesh : NSObject

@property (nonatomic, assign) TreeVertex* vertices;
@property (nonatomic, assign) NSUInteger numberOfVertices;
@property (nonatomic, assign) Index* indices;
@property (nonatomic, assign) NSUInteger numberOfIndices;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) CC3BoundingBox boundingBox;

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton;
- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton andNumberOfRadialSegments:(int)numberOfRadialSegments;

- (void)addCircleVerticesWithTransform:(CC3GLMatrix*)transform
                             andRadius:(float)radius
                           andSegments:(NSInteger)segments
                           andTextureY:(float)textureY
                      andTextureStartX:(float)textureStartX
                       andTextureSpanX:(float)textureSpanX
                           andVertices:(NSMutableArray*)vertices
                              andBone1:(NSInteger)bone1
                              andBone2:(NSInteger)bone2;

@end
