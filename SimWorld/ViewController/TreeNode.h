//
//  TreeNode.h
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "REKeyframedMeshNode.h"

@interface TreeType : NSObject

@property (atomic) int identifier;
@property (nonatomic, retain) NSString *name;

+ (TreeType *)treeWithIdentifier:(int)identifier andName:(NSString *)name;

- (id)initWithIdentifier:(int)identifier andName:(NSString *)name;

@end

#define TREE_TYPE_BIRCH         [TreeType treeWithIdentifier:0 andName:@"Birch"]
#define TREE_TYPE_PINE          [TreeType treeWithIdentifier:1 andName:@"Pine"]
#define TREE_TYPE_GARDENWOOD    [TreeType treeWithIdentifier:2 andName:@"Gardenwood"]
#define TREE_TYPE_GRAYWOOD      [TreeType treeWithIdentifier:3 andName:@"Graywood"]
#define TREE_TYPE_RUG           [TreeType treeWithIdentifier:4 andName:@"Rug"]
#define TREE_TYPE_WILLOW        [TreeType treeWithIdentifier:5 andName:@"Willow"]

#define TREE_TYPES              @[TREE_TYPE_BIRCH, TREE_TYPE_PINE, TREE_TYPE_GARDENWOOD, TREE_TYPE_GRAYWOOD, TREE_TYPE_RUG, TREE_TYPE_WILLOW]

@interface TreeNode : REKeyframedMeshNode

@property (atomic) BOOL showTrunk;
@property (atomic) BOOL showLeaves;

- (id)initWithType:(TreeType *)tree;

@end
