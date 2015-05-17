//
//  HexagonMesh.m
//  SimWorld
//
//  Created by Michael Rommel on 15.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexagonMesh.h"

@implementation HexagonMesh

- (id)initWithX:(float)x andY:(float)y andZ:(float)z andTextureFile:(NSString *)textureName
{
    self = [super initWithNumberOfVertices:7 andNumberOfIndices:18 andTextureFile:textureName];
    
    if (self) {
        //   6---1
        //  / \ / \
        // 5---0---2
        //  \ / \ /
        //   4---3
        [self setVertexAt:0 andX:(0.0f+x) andY:y andZ:(0.0f+z) andTextureX:0.5f andTextureY:0.5f];
        [self setVertexAt:1 andX:(0.2f+x) andY:y andZ:(-0.5f+z) andTextureX:0.7f andTextureY:0.0f];
        [self setVertexAt:2 andX:(0.5f+x) andY:y andZ:(0.0f+z) andTextureX:1.0f andTextureY:0.5f];
        [self setVertexAt:3 andX:(0.2f+x) andY:y andZ:(0.5f+z) andTextureX:0.7f andTextureY:1.0f];
        [self setVertexAt:4 andX:(-0.2f+x) andY:y andZ:(0.5f+z) andTextureX:0.3f andTextureY:1.0f];
        [self setVertexAt:5 andX:(-0.5f+x) andY:y andZ:(0.0f+z) andTextureX:0.0f andTextureY:0.5f];
        [self setVertexAt:6 andX:(-0.2f+x) andY:y andZ:(-0.5f+z) andTextureX:0.3f andTextureY:0.0f];
        
        [self setTriangleAt:0 withIndex1:0 andIndex2:1 andIndex3:2];
        [self setTriangleAt:0 withIndex1:0 andIndex2:1 andIndex3:2];
        [self setTriangleAt:1 withIndex1:0 andIndex2:2 andIndex3:3];
        [self setTriangleAt:2 withIndex1:0 andIndex2:3 andIndex3:4];
        [self setTriangleAt:3 withIndex1:0 andIndex2:4 andIndex3:5];
        [self setTriangleAt:4 withIndex1:0 andIndex2:5 andIndex3:6];
        [self setTriangleAt:5 withIndex1:0 andIndex2:6 andIndex3:1];
    }
    
    return self;
}

@end
