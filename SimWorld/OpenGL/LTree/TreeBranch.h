//
//  TreeBranch.h
//  SimWorld
//
//  Created by Michael Rommel on 12.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeBranch : NSObject

/// <summary>
/// Rotation relative to the branch's parent.
/// </summary>
@property (retain) CC3GLMatrix *rotation;

/// <summary>
/// Length of the branch.
/// </summary>
@property (atomic) float length;

/// <summary>
/// Radius at the start of the branch.
/// </summary>
@property (atomic) float startRadius;

/// <summary>
/// Radius at the end of the branch.
/// </summary>
@property (atomic) float endRadius;

/// <summary>
/// Index of the parent branch, or -1 if this is the root branch.
/// </summary>
@property (atomic) NSUInteger parentIndex;

/// <summary>
/// Where on the parent the branch is located. 0.0f is at the start, 1.0f is at the end.
/// </summary>
@property (atomic) float parentPosition;

/// <summary>
/// Index of the bone controlling this branch.
/// </summary>
@property (atomic) NSUInteger boneIndex;

- (id)initWithQuaternion:(CC3GLMatrix *)rotation
               andLength:(float)length
                andStart:(float)startRadius
                  andEnd:(float)endRadius
          andParentIndex:(int)parentIndex
       andParentPosition:(int)parentPosition;

@end
