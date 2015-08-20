//
//  TreeSkeleton.h
//  SimWorld
//
//  Created by Michael Rommel on 10.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeBranch;
@class TreeLeaf;
@class TreeBone;

#import "CC3GLMatrix+Extension.h"

@interface TreeSkeleton : NSObject

@property (nonatomic, retain) NSMutableArray *branches; // TreeBranch
@property (nonatomic, retain) NSMutableArray *leaves; // TreeLeaf
@property (nonatomic, retain) NSMutableArray *bones; // TreeBone
@property (atomic) float textureHeight;
@property (nonatomic, retain) CC3GLVector *leafAxis;

- (id)init;

- (void)copyAbsoluteBranchTransformsTo:(NSMutableArray *)destinationMatrices;
- (void)copyAbsoluteBoneTranformsTo:(NSMutableArray *)destinationMatrices andBoneRotation:(NSMutableArray *)boneRotations;

- (float)longestBranching:(NSMutableArray *)destinationArray;

- (TreeBranch *)branchAtIndex:(NSUInteger)branchIndex;
- (void)insertBranch:(TreeBranch *)branch atIndex:(NSUInteger)branchIndex;
- (void)addBranch:(TreeBranch *)branch;

- (TreeLeaf *)leaveAtIndex:(int)leaveIndex;
- (void)addLeave:(TreeLeaf *)leaf;

- (TreeBone *)boneAtIndex:(NSUInteger)boneIndex;
- (void)addBone:(TreeBone *)bone;

- (float)trunkRadius;

/// @brief Sets the EndRadius to 0.0f on all branches without children.
/// This is automatically called by the TreeGenerator.
- (void)closeEdgeBranches;

@end
