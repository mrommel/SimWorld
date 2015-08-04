//
//  TreeCrayon.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCrayon.h"

#import "MiRoStack.h"
#import "TreeSkeleton.h"
#import "TreeContraints.h"
#import "CC3GLMatrix.h"
#import "TreeBone.h"
#import "TreeBranch.h"
#import "CC3GLMatrix+Extension.h"

@interface TreeCrayonState : NSObject

@property (atomic) NSInteger parentIndex;
@property (atomic) float parentPosition;
@property (atomic) float scale;
@property (nonatomic, retain) CC3GLMatrix *rotation;
@property (atomic) int level;
@property (atomic) float radiusScale;
@property (atomic) int parentBoneIndex;
@property (atomic) int boneLevel;

@end

@implementation TreeCrayonState

@end

@interface TreeCrayon() {
    
}

@property (nonatomic, retain) TreeCrayonState *state;
@property (nonatomic, retain) MiRoStack *stack;
@property (nonatomic, retain) NSMutableArray *branchTransforms; // Matrix
@property (nonatomic, retain) NSMutableArray *boneEndings; // Map from bone index to branch where it was created // int

#define MaxBones 20

@end

@implementation TreeCrayon

- (id)init
{
    self = [super init];
    
    if (self) {
        self.state = [[TreeCrayonState alloc] init];
        self.state.parentIndex = -1;
        self.state.parentPosition = 1.0f;
        self.state.scale = 1.0f;
        self.state.rotation = [[CC3GLMatrix alloc] initIdentity];
        self.state.level = 1;
        self.state.radiusScale = 1.0f;
        self.state.parentBoneIndex = -1;
        self.state.boneLevel = 0;
        
        self.boneLevels = 3;
        
        self.skeleton = [[TreeSkeleton alloc] init];
    }
    
    return self;
}

- (int)level
{
    return self.state.level;
}

- (void)setLevel:(int)level
{
    self.state.level = level;
}

- (float)currentScale
{
    return self.state.scale;
}

- (CC3GLMatrix *)transform
{
    CC3GLMatrix *m = [CC3GLMatrix identity];
    [m populateFromQuaternion:[self.state.rotation extractQuaternion]];
    if (self.state.parentIndex == -1)
        return m;
    
    m.glMatrix[13] = self.state.parentPosition * [self.skeleton branchAtIndex:self.state.parentIndex].length;
    [m multiplyByMatrix:[self.branchTransforms matrixAtIndex:self.state.parentIndex]];
    return m;
}

- (void)executeBoneWithDelta:(int)delta
{
    if ((self.state.boneLevel > self.boneLevels + delta) || (self.skeleton.bones.count == MaxBones)) {
        return;
    }
    
    // Get index of the parent
    int parent = self.state.parentBoneIndex;
    
    // Get the parent's absolute transform
    CC3GLMatrix *parentTransform = [CC3GLMatrix identity];
    CC3GLMatrix *parentInverseTransform = [CC3GLMatrix identity];
    float parentLength = 0.0f;
    if (parent != -1)
    {
        parentTransform = [self.skeleton boneAtIndex:parent].referenceTransform;
        parentInverseTransform = [self.skeleton boneAtIndex:parent].inverseReferenceTransform;
        parentLength = [self.skeleton boneAtIndex:parent].length;
    }
    
    // Find the starting and ending point of the new bone
    CC3Vector targetLocation = [[self transform] extractTranslation];
    CC3Vector fromLocation = CC3VectorAdd([parentTransform extractTranslation], CC3VectorScaleUniform([parentTransform extractUpDirection], parentLength));
    
    // Direction of the bone's Y-axis
    CC3Vector directionY = CC3VectorNormalize(CC3VectorDifference(targetLocation, fromLocation));
    
    // Choose arbitrary perpendicular X and Z axes
    CC3Vector directionX;
    CC3Vector directionZ;
    if (directionY.y < 0.50f)
    {
        directionX = CC3VectorNormalize(CC3VectorCross(directionY, kCC3VectorUp));
        directionZ = CC3VectorNormalize(CC3VectorCross(directionX, directionY));
    }
    else
    {
        directionX = CC3VectorNormalize(CC3VectorCross(directionY, kCC3VectorBackward));
        directionZ = CC3VectorNormalize(CC3VectorCross(directionX, directionY));
    }
    
    // Construct the absolute rotation of the child
    CC3GLMatrix *childAbsoluteTransform = [CC3GLMatrix identity];
    [childAbsoluteTransform setRightDirection:directionX];
    [childAbsoluteTransform setUpDirection:directionY];
    [childAbsoluteTransform setBackwardDirection:directionZ];
    [childAbsoluteTransform setTranslation:fromLocation];
    
    // Calculate the relative transformation
    CC3GLMatrix *relativeTransformation = [childAbsoluteTransform copyMultipliedBy:parentInverseTransform];
    CC3GLMatrix *rotation = [CC3GLMatrix identity];
    [rotation populateFromQuaternion:[relativeTransformation extractQuaternion]];
    
    // Create the new bone
    TreeBone *bone = [[TreeBone alloc] init];
    bone.referenceTransform = childAbsoluteTransform;
    bone.inverseReferenceTransform = [bone.referenceTransform copyInverted];
    bone.length = CC3VectorDistance(fromLocation, targetLocation);
    bone.rotation = rotation;
    bone.parentIndex = parent;
    bone.stiffness = [self.skeleton branchAtIndex:self.state.parentIndex].startRadius; // 1.0f; // TODO: Set stiffness according to radius
    bone.endBranchIndex = self.state.parentIndex;
    
    // Add the bone to the skeleton
    [self.skeleton addBone:bone];
    
    // Set this bone as the parent
    NSInteger endIndex = (self.state.parentBoneIndex == -1 ? -1 : [self.skeleton boneAtIndex:self.state.parentBoneIndex].endBranchIndex);
    NSInteger boneIndex = self.state.parentBoneIndex = self.skeleton.bones.count - 1L;
    self.state.boneLevel -= delta;
    
    // Update the bone index on branches
    NSInteger branchIndex = self.state.parentIndex;
    while (branchIndex != endIndex)
    {
        TreeBranch *branch = [self.skeleton branchAtIndex:branchIndex];
        branch.boneIndex = boneIndex;
        [self.skeleton insertBranch:branch atIndex:branchIndex];
        branchIndex = branch.parentIndex;
    }
}

@end
