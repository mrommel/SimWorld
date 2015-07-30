//
//  TreeLeaf.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeLeaf.h"

@implementation TreeLeaf

- (id)initWithParentIndex:(int)parentIndex
                 andColor:(ccColor4F)color
              andRotation:(float)rotation
                  andSize:(CC2Vector)size
             andBoneIndex:(int)boneIndex
            andAxisOffset:(float)axisOffset
{
    self = [super init];
    
    if (self) {
        self.parentIndex = parentIndex;
        self.color = color;
        self.rotation = rotation;
        self.size = size;
        self.boneIndex = boneIndex;
        self.axisOffset = axisOffset;
    }
    
    return self;
}

@end