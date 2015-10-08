//
//  TreeVertex.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeVertex.h"

TreeVertex TreeVertexMake(CC3Vector position, CC3Vector normal, CC3Vector2 textureCoordinate, int bone1, int bone2)
{
    TreeVertex tv;
    tv.Position[0] = position.x;
    tv.Position[1] = position.y;
    tv.Position[2] = position.z;
    tv.Normal[0] = normal.x;
    tv.Normal[1] = normal.y;
    tv.Normal[2] = normal.z;
    tv.TexCoord[0] = textureCoordinate.x;
    tv.TexCoord[1] = textureCoordinate.y;
    tv.Bones[0] = bone1, tv.Bones[1] = bone2;
    return tv;
}
