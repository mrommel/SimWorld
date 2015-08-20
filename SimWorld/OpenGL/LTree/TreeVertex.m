//
//  TreeVertex.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeVertex.h"

BoneIndex BoneIndexMake(NSUInteger bone1, NSUInteger bone2)
{
    BoneIndex bi;
    bi.bone1 = bone1;
    bi.bone2 = bone2;
    return bi;
}

@implementation TreeVertex

- (id)initWithTranslation:(CC3Vector)translation andDirection:(CC3Vector)direction andTextureCoords:(CC3Vector2)textureCoord andBone1:(NSUInteger)bone1 andBone2:(NSUInteger)bone2
{
    self = [super init];
    
    if (self) {
        self.position = translation;
        self.normal = direction;
        self.textureCoordinate = textureCoord;
        self.bones = BoneIndexMake(bone1, bone2);
    }
    
    return self;
}

@end
