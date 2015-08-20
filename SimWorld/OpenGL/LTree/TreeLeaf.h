//
//  TreeLeaf.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
    float Offset[2];
    int   BoneIndex;
    float BranchNormal[3];
} LeafVertex;

LeafVertex LeafVertexMake(CC3Vector position, ccColor4F color, CC3Vector2 texcoord, CC3Vector2 offset, int boneIndex, CC3Vector branchNormal);


@interface TreeLeaf : NSObject

/// <summary>
/// Index of the branch carrying the leaf.
/// </summary>
@property (atomic) NSInteger parentIndex;

/// <summary>
/// Color tint of the leaf.
/// </summary>
@property (atomic) ccColor4F color;

/// <summary>
/// Rotation of the leaf, in radians.
/// </summary>
@property (atomic) float rotation;

/// <summary>
/// Width and height of the leaf.
/// </summary>
@property (atomic) CC3Vector2 size;

/// <summary>
/// Index of the bone controlling this leaf.
/// </summary>
@property (atomic) NSInteger boneIndex;

/// <summary>
/// Leaf's position offset along the leaf axis. Only used when the leaf axis is non-null on the tree skeleton.
/// LeafAxis * AxisOffset will be added to the leaf's position on the branch.
/// </summary>
@property (atomic) float axisOffset;

- (id)initWithParentIndex:(int)parentIndex
                 andColor:(ccColor4F)color
              andRotation:(float)rotation
                  andSize:(CC3Vector2)size
             andBoneIndex:(int)boneIndex
            andAxisOffset:(float)axisOffset;
@end
