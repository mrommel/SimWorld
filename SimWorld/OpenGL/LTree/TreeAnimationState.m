//
//  TreeAnimationState.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeAnimationState.h"

#import "TreeSkeleton.h"
#import "TreeBone.h"

@implementation TreeAnimationState

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton
{
    self = [super init];
    
    if (self) {
        self.rotations = [[NSMutableArray alloc] initWithCapacity:skeleton.bones.count];
        for (int i = 0; i < skeleton.bones.count; i++) {
            [self.rotations insertObject:[skeleton boneAtIndex:i].rotation atIndex:i];
        }
    }
    
    return self;
}

@end
