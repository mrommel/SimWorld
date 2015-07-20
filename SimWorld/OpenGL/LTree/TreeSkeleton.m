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

@implementation TreeSkeleton

@synthesize bones;
@synthesize branches;
@synthesize leaves;
@synthesize textureHeight;

/// <summary>
/// Calculates the absolute transform of each branch, and copies it into a given matrix array.
/// </summary>
/// <param name="destinationMatrices">Where to store the branch transforms. The matrix at index N corresponds to the branch at index N.</param>
- (void)copyAbsoluteBranchTransformsTo:(NSMutableArray *)destinationMatrices
{
    NSAssert(destinationMatrices != nil, @"destinationMatrices");
    NSAssert(destinationMatrices.count >= branches.count, @"Destination array is too small.");
    
    for (int i = 0; i < self.branches.count; i++)
    {
        // Get rotation matrix relative to parent (if any)
        CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrix];
        TreeBranch *branch = [branches objectAtIndex:i];
        [rotationMatrix populateFromQuaternion:[branch.rotation extractQuaternion]];
        
        int parent = branch.parentIndex;
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
        float dist = [[self.branches objectAtIndex:i] length];
        int parentIndex = ((TreeBranch *)[self.branches objectAtIndex:i]).parentIndex;
        if (parentIndex != -1) {
            dist += [[destinationArray objectAtIndex:parentIndex] floatValue]
            - [[branches objectAtIndex:parentIndex] length] * (1.0f - ((TreeBranch *)[self.branches objectAtIndex:i]).parentPosition);
        }
        if (dist > maxdist)
            maxdist = dist;
        [destinationArray insertObject:[NSNumber numberWithFloat:dist] atIndex:i];
    }
    
    return maxdist;
}

- (TreeBranch *)branchAtIndex:(int)branchIndex
{
    return [self.branches objectAtIndex:branchIndex];
}

- (TreeLeaf *)leaveAtIndex:(int)leaveIndex
{
    return [self.leaves objectAtIndex:leaveIndex];
}

- (TreeBone *)boneAtIndex:(int)boneIndex
{
    return [self.bones objectAtIndex:boneIndex];
}

- (float)trunkRadius
{
    return [self branchAtIndex:0].startRadius;
}

@end
