//
//  TreeSkeleton.m
//  SimWorld
//
//  Created by Michael Rommel on 10.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeSkeleton.h"

#import <GLKit/GLKit.h>
#import "TreeBranch.h"
#import "TreeLeaf.h"
#import "TreeBone.h"
#import "CC3GLMatrix+Extension.h"

@implementation TreeSkeleton

@synthesize bones;
@synthesize branches;
@synthesize leaves;
@synthesize textureHeight;

- (id)initWithName:(NSString *)name;
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.branches = [[NSMutableArray alloc] init];
        self.leaves = [[NSMutableArray alloc] init];
        self.bones = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/// <summary>
/// Calculates the absolute transform of each branch, and copies it into a given matrix array.
/// </summary>
/// <param name="destinationMatrices">Where to store the branch transforms. The matrix at index N corresponds to the branch at index N.</param>
- (void)copyAbsoluteBranchTransformsTo:(NSMutableArray *)destinationMatrices
{
    NSAssert(destinationMatrices != nil, @"destinationMatrices");
    NSAssert(destinationMatrices.count == self.branches.count, @"Destination array is too small.");
    
    for (int i = 0; i < self.branches.count; i++)
    {
        // Get rotation matrix relative to parent (if any)
        CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrix];
        TreeBranch *branch = [branches objectAtIndex:i];
        [rotationMatrix populateFromQuaternion:[branch.rotation extractQuaternion]];
        
        NSInteger parent = branch.parentIndex;
        if (parent == -1)
        {
            // This is the root branch
            [destinationMatrices insertObject:rotationMatrix atIndex:i];
        }
        else
        {
            // Translate the branch along its parent. (M42 is the Y-coordinate of the translation vector)
            TreeBranch *parentBranch = [branches objectAtIndex:parent];
            [rotationMatrix translateByY:(branch.parentPosition * parentBranch.length)];
            
            // Transform by parent's absolute matrix
            CC3GLMatrix *parentMatrix = [CC3GLMatrix matrix];
            [parentMatrix populateFrom:rotationMatrix];
            [parentMatrix multiplyByMatrix:[destinationMatrices objectAtIndex:parent]];
            [destinationMatrices insertObject:parentMatrix atIndex:i];
        }
    }
}

- (void)copyAbsoluteBoneTranformsTo:(NSMutableArray *)destinationArray andBoneRotation:(NSMutableArray *)boneRotations
{
    NSAssert(destinationArray.count == self.bones.count, @"Destination array is too small. dest: %d, bones: %d", destinationArray.count, self.bones.count);
    NSAssert(boneRotations.count == self.bones.count, @"Rotations array is too small to be a proper animation state.");
    
    for (int i = 0; i < bones.count; i++) {
        //[destinationArray insertObject:[CC3GLMatrix matrixFromQuaternion:[boneRotations vector4AtIndex:i]] atIndex:i];
        [destinationArray insertObject:[boneRotations matrixAtIndex:i] atIndex:i];
        if ([self boneAtIndex:i].parentIndex != -1) {
            float m42 = [self boneAtIndex:[self boneAtIndex:i].parentIndex].length;
            CC3GLMatrix *destination = [destinationArray matrixAtIndex:i];
            [destination setTranslationY:m42];
            [destination multiplyByMatrix:[destinationArray matrixAtIndex:[self boneAtIndex:i].parentIndex]];
            [destinationArray replaceObjectAtIndex:i withObject:destination];
        }
    }
}

/// <summary>
/// Finds the distance from the root to the tip of each branch, and writes it in an array.
/// Then returns the longest of those distances found.
/// </summary>
/// <param name="destinationArray">Destination array to put distances into.</param>
/// <returns>Longest root-to-branch-tip distance found</returns>
/// <exception cref="ArgumentException">If the destination array is too short.</exception>
- (float)longestBranching:(NSMutableArray *)destinationArray
{
    NSAssert(destinationArray.count >= self.branches.count, @"Destination array is too small.");
    
    float maxdist = 0.0f;
    for (int i = 0; i < self.branches.count; i++)
    {
        float dist = [[self branchAtIndex:i] length];
        NSInteger parentIndex = [self branchAtIndex:i].parentIndex;
        if (parentIndex != -1) {
            dist += [[destinationArray objectAtIndex:parentIndex] floatValue]
            - [[branches objectAtIndex:parentIndex] length] * (1.0f - ((TreeBranch *)[self.branches objectAtIndex:i]).parentPosition);
        }
        if (dist > maxdist)
            maxdist = dist;
        [destinationArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:dist]];
    }
    
    return maxdist;
}

#pragma mark -


- (TreeBranch *)branchAtIndex:(NSUInteger)branchIndex
{
    return [self.branches objectAtIndex:branchIndex];
}

- (void)insertBranch:(TreeBranch *)branch atIndex:(NSUInteger)branchIndex
{
    [self.branches insertObject:branch atIndex:branchIndex];
}

- (void)addBranch:(TreeBranch *)branch
{
    [self.branches addObject:branch];
}

- (TreeLeaf *)leaveAtIndex:(int)leaveIndex
{
    return [self.leaves objectAtIndex:leaveIndex];
}

- (void)addLeave:(TreeLeaf *)leaf
{
    [self.leaves addObject:leaf];
}

- (TreeBone *)boneAtIndex:(NSUInteger)boneIndex
{
    return [self.bones objectAtIndex:boneIndex];
}

- (void)addBone:(TreeBone *)bone
{
    [self.bones addObject:bone];
}

- (float)trunkRadius
{
    return [self branchAtIndex:0].startRadius;
}

- (void)closeEdgeBranches
{
    // Create a map of all the branches to remember if it is a parent or not
    NSMutableArray *parentmap = [[NSMutableArray alloc] initWithCapacity:branches.count];
    
    for (int i = 0; i < branches.count; i++) {
        [parentmap addObject:@NO];
    }
    
    for (NSInteger i = self.branches.count - 1; i >= 0; --i) {
        NSInteger parent = [self branchAtIndex:i].parentIndex;
        if (parent != -1)
            [parentmap replaceObjectAtIndex:parent withObject:@YES];
        if (![[parentmap objectAtIndex:i] boolValue]) {
            TreeBranch *branch = [self branchAtIndex:i];
            branch.endRadius = 0.0f;
            [branches replaceObjectAtIndex:i withObject:branch];
        }
    }
}

@end
