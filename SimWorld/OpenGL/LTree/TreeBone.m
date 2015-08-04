//
//  TreeBone.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeBone.h"

@implementation TreeBone

- (id)initWithRotation:(CC3GLMatrix *)rotation
        andParentIndex:(int)parentIndex
 andReferenceTransform:(CC3GLMatrix *)referenceTransform
andInverseReferenceTransform:(CC3GLMatrix *)inverseReferenceTransform
             andLength:(float)length
          andStiffness:(float)stiffness
     andEndBranchIndex:(int)endBranchIndex
{
    self = [super init];
    
    if (self) {
        self.rotation = rotation;
        self.parentIndex = parentIndex;
        self.referenceTransform = referenceTransform;
        self.inverseReferenceTransform = inverseReferenceTransform;
        self.length = length;
        self.stiffness = stiffness;
        self.endBranchIndex = endBranchIndex;
    }
    
    return self;
}

@end
