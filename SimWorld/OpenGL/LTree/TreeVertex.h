//
//  TreeVertex.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

typedef struct
{
    NSUInteger bone1;
    NSUInteger bone2;
} BoneIndex;

/** Returns a BoneIndex structure constructed from the bone components. */
BoneIndex BoneIndexMake(NSUInteger bone1, NSUInteger bone2);

@interface TreeVertex : NSObject

/// <summary>
/// Position of the vertex, in object space.
/// </summary>
@property (atomic) CC3Vector position;

/// <summary>
/// Vertex normal, in object space.
/// </summary>
@property (atomic) CC3Vector normal;

/// <summary>
/// Texture coordinates.
/// </summary>
@property (atomic) CC3Vector2 textureCoordinate;

/// <summary>
/// Index of the bones. Set Bone1=Bone2 if only one bone is effective.
/// </summary>
/// <remarks>
/// For the reference shader, this should be passed as a short2 in TEXCOORD1.
/// </remarks>
@property (atomic) BoneIndex bones;

- (id)initWithTranslation:(CC3Vector)translation andDirection:(CC3Vector)direction andTextureCoords:(CC3Vector2)textureCoord andBone1:(NSUInteger)bone1 andBone2:(NSUInteger)bone2;

@end
