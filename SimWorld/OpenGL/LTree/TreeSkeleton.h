//
//  TreeSkeleton.h
//  SimWorld
//
//  Created by Michael Rommel on 10.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeBranch;

@interface TreeSkeleton : NSObject

@property (retain) NSMutableArray *branches; // TreeBranch
@property (retain) NSMutableArray *leaves; // TreeLeaf
@property (retain) NSMutableArray *bones; // TreeBone
@property (atomic) float textureHeight;

- (void)copyAbsoluteBranchTransformsTo:(NSMutableArray *)destinationMatrices;
- (float)longestBranching:(NSMutableArray *)destinationArray;

- (TreeBranch *)branchAtIndex:(int)branchIndex;

@end
