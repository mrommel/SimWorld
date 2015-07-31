//
//  TreeCrayon.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeContraints;
@class TreeSkeleton;

@interface TreeCrayon : NSObject

@property (atomic) int level;
@property (atomic) int boneLevels;
@property (nonatomic, retain) TreeContraints *constraints;
@property (nonatomic, retain) TreeSkeleton *skeleton;
@property (atomic, readonly) float currentScale;

- (id)init;

- (void)executeBoneWithDelta:(int)delta;

@end
