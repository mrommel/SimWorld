//
//  TreeBranch.m
//  SimWorld
//
//  Created by Michael Rommel on 12.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeBranch.h"

@implementation TreeBranch

- (id)initWithQuaternion:(CC3GLMatrix *)rotation
               andLength:(float)length
                andStart:(float)startRadius
                  andEnd:(float)endRadius
          andParentIndex:(int)parentIndex
       andParentPosition:(int)parentPosition
{
    self = [super init];
    if (self) {
        self.rotation = rotation;
        self.length = length;
        self.startRadius = startRadius;
        self.endRadius = endRadius;
        self.parentIndex = parentIndex;
        self.parentPosition = parentPosition;
        self.boneIndex = -1;
    }
    return self;
}

@end
