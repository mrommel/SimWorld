//
//  TreeCrayon.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

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

- (CC3GLMatrix *)transform;

- (void)pushState;
- (void)popState;

// instrctions
- (void)forwardWithDistance:(float)distance andRadius:(float)radius;
- (void)backwardWithDistance:(float)distance;
- (void)pitchWithAngle:(float)angle;
- (void)scaleBy:(float)value;
- (void)scaleRadiusBy:(float)value;
- (void)twistByAngle:(float)angleInRadians;
- (void)leafWithRotation:(float)rotation andSize:(CC3Vector2)size andColor:(CC3Vector4)color andAxisOffset:(float)axisOffset;

@end
