//
//  TreeNode.h
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "REKeyframedMeshNode.h"

typedef enum {
    TreeTypeNormal
} TreeType;

@interface TreeNode : REKeyframedMeshNode

- (id)initWithType:(TreeType)type;

@end
