//
//  TreeAnimationState.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeSkeleton;

@interface TreeAnimationState : NSObject

@property (nonatomic, retain) NSMutableArray* rotations;

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton;

@end
