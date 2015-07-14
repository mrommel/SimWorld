//
//  TreeMesh.h
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeSkeleton;

@interface TreeMesh : NSObject

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton;
- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton andNumberOfRadialSegments:(int)numberOfRadialSegments;

@end
