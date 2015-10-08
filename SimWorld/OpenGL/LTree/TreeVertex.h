//
//  TreeVertex.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

/*typedef struct
{
    float bone1;
    float bone2;
} BoneIndex;

/** Returns a BoneIndex structure constructed from the bone components. * /
BoneIndex BoneIndexMake(NSUInteger bone1, NSUInteger bone2);*/

typedef struct {
    /// <summary>
    /// Position of the vertex, in object space.
    /// </summary>
    float Position[3];
    
    /// <summary>
    /// Vertex normal, in object space.
    /// </summary>
    float Normal[3];
    
    /// <summary>
    /// Texture coordinates.
    /// </summary>
    float TexCoord[2];
    
    /// <summary>
    /// Index of the bones. Set Bone1=Bone2 if only one bone is effective.
    /// </summary>
    /// <remarks>
    /// For the reference shader, this should be passed as a short2 in TEXCOORD1.
    /// </remarks>
    float Bones[2];
} TreeVertex;

TreeVertex TreeVertexMake(CC3Vector position, CC3Vector normal, CC3Vector2 textureCoordinate, int bone1, int bone2);

static const TreeVertex kTreeVertexZero = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0 };

