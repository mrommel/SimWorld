//
//  SimpleTree.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "SimpleTree.h"

#import "TreeSkeleton.h"
#import "TreeMesh.h"
#import "TreeLeafCloud.h"
#import "TreeAnimationState.h"

@implementation SimpleTree

- (id)initWithSkeleton:(TreeSkeleton *)skeleton
{
    self = [super init];
    
    if (self) {
        [self populateWithSkeleton:skeleton];
    }
    
    return self;
}

- (void)populateWithSkeleton:(TreeSkeleton *)skeleton
{
    self.trunk = [[TreeMesh alloc] initWithTreeSkeleton:skeleton];
    self.leaves = [[TreeLeafCloud alloc] initWithTreeSkeleton:skeleton];
    self.animationState = [[TreeAnimationState alloc] initWithTreeSkeleton:skeleton];
    self.bindingMatrices = [[NSMutableArray alloc] initWithCapacity:skeleton.bones.count];
}

@end
