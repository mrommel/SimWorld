//
//  TreeMesh.m
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeMesh.h"

#import "TreeSkeleton.h"

@interface TreeMesh() {
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    int _numVertices;
    int _numtriangles;
    int _maxRadialSegments;
}

@end

@implementation TreeMesh

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton
{
    _maxRadialSegments = 8;
    
    self = [super init];
    
    if (self) {
        [self loadFromSkeleton:skeleton];
    }
    
    return self;
}

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton andNumberOfRadialSegments:(int)numberOfRadialSegments
{
    _maxRadialSegments = numberOfRadialSegments;
    
    self = [super init];
    
    if (self) {
        [self loadFromSkeleton:skeleton];
    }
    
    return self;
}

- (void)loadFromSkeleton:(TreeSkeleton *)skeleton
{
    NSAssert(skeleton.branches.count > 0, @"Tree skeleton had no branches")
    NSAssert(_maxRadialSegments > 2, @"Tree must have at least 3 radial segments");
}

- (void)draw
{
    
}

@end
