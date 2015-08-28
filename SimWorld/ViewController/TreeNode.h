//
//  TreeNode.h
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "REKeyframedMeshNode.h"

#define TREE_TYPE_BIRCH         0
#define TREE_TYPE_PINE          1
#define TREE_TYPE_GARDENWOOD    2
#define TREE_TYPE_GRAYWOOD      3
#define TREE_TYPE_RUG           4
#define TREE_TYPE_WILLOW        5
#define TREE_TYPES              6

@interface TreeNode : REKeyframedMeshNode

@property (atomic) BOOL showTrunk;
@property (atomic) BOOL showLeaves;

- (id)initWithType:(NSUInteger)tree;

@end
