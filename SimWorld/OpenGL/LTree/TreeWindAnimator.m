//
//  TreeWindAnimator.m
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeWindAnimator.h"

#import "WindSource.h"
#import "TreeSkeleton.h"
#import "TreeAnimationState.h"
#import "TreeBone.h"
#import "CC3GLMatrix+Extension.h"

@interface TreeWindAnimator() {
    
}

@property (nonatomic, retain) WindSource *wind;

@end

@implementation TreeWindAnimator

- (id)initWithWind:(WindSource *)source
{
    self = [super init];
    
    if (self) {
        self.wind = source;
    }
    
    return self;
}

- (void)animateTreeSkeleton:(TreeSkeleton *)skeleton andAnimationState:(TreeAnimationState *)state andSeconds:(float)seconds
{
    NSMutableArray *transforms = [[NSMutableArray alloc] initWithCapacity:skeleton.bones.count];
    [skeleton copyAbsoluteBoneTranformsTo:transforms andBoneRotation:state.rotations];
    
    for (int i = 0; i < state.rotations.count; i++)
    {
        CC3Vector dir = [[skeleton boneAtIndex:i].rotation transformDirection:kCC3VectorUp];
        CC3Vector windstr = [self.wind windStrengthForPosition:kCC3VectorZero];
        CC3Vector axis = CC3VectorCross(dir, windstr);
        float strength = CC3VectorLength(axis);
        axis = CC3VectorNormalize(axis);
        
        // Move the axis from tree space into branch space
        axis = [[skeleton boneAtIndex:i].inverseReferenceTransform transformNormal:axis];
        
        // Normalize strength
        strength = 1.0f - expf(-0.01f * strength / [skeleton boneAtIndex:i].stiffness);
        
        //Quaternion.CreateFromAxisAngle(axis, strength * MathHelper.PiOver2);
        CC3GLMatrix *q = [[CC3GLMatrix alloc] init];
        [q populateFromQuaternion:CC3Vector4Make(axis.x, axis.y, axis.z, strength * M_PI_2)];
        CC3GLMatrix *tmp = [[skeleton boneAtIndex:i].rotation copy];
        [tmp multiplyByMatrix:q];
        [state.rotations insertMatrix:tmp atIndex:i];
    }
}

@end
