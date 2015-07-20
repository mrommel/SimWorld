//
//  TreeBone.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeBone : NSObject

/// <summary>
/// Bone's rotation relative to its parent, in the frame of reference.
/// </summary>
@property (nonatomic, retain) CC3GLMatrix *rotation;

/// <summary>
/// Index of the bone's parent, or -1 if this is the root bone.
/// </summary>
@property (atomic) NSUInteger parentIndex;

/// <summary>
/// Absolute transformation in the frame of reference.
/// </summary>
@property (nonatomic, retain) CC3GLMatrix *referenceTransform;

/// <summary>
/// Inverse absolute transformation in the frame of reference.
/// </summary>
@property (nonatomic, retain) CC3GLMatrix *inverseReferenceTransform;

/// <summary>
/// Length of the bone.
/// </summary>
@property (atomic) float length;

/// <summary>
/// Resistance to wind. By default, this is determined by the radius of the branch that spawned the bone.
/// </summary>
@property (atomic) float stiffness;

/// <summary>
/// Index of the branch where the bone ends. Note that both ancestors and children of this branch
/// may be controlled by this bone.
/// </summary>
@property (atomic) NSUInteger endBranchIndex;

@end
