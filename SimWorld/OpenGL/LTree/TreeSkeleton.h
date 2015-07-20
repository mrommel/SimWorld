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

@interface TreeSkeleton : NSObject

@property (retain) NSMutableArray *branches; // TreeBranch
@property (retain) NSMutableArray *leaves; // TreeLeaf
@property (retain) NSMutableArray *bones; // TreeBone
@property (atomic) float textureHeight;
@property (atomic) CC3Vector *leafAxis;

- (void)copyAbsoluteBranchTransformsTo:(NSMutableArray *)destinationMatrices;
- (float)longestBranching:(NSMutableArray *)destinationArray;

- (TreeBranch *)branchAtIndex:(int)branchIndex;
- (TreeLeaf *)leaveAtIndex:(int)leaveIndex;
- (TreeBone *)boneAtIndex:(int)boneIndex;

- (float)trunkRadius;

@end
