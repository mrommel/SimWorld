//
//  CC3GLMatrix+Extension.h
//  SimWorld
//
//  Created by Michael Rommel on 15.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    GLfloat x;			/**< The X-componenent of the vector. */
    GLfloat y;			/**< The Y-componenent of the vector. */
} CC2Vector;

/** Returns a CC2Vector structure constructed from the vector components. */
CC2Vector CC2VectorMake(GLfloat x, GLfloat y);

CC2Vector CC2VectorScaleUniform(CC2Vector v, GLfloat scale);

GLfloat CC2VectorLength(CC2Vector v);


/**
 * Defines an axially-aligned-bounding-sphere (AABB), describing
 * a 3D volume by specifying the center in 3D corner and a radius.
 */
typedef struct {
    CC3Vector center;			/**< The center of the sphere. */
    float radius;			/**< The radius of the sphere */
} CC3BoundingSphere;

/** A CC3BoundingSphere of zero origin and dimensions. */
static const CC3BoundingSphere kCC3CC3BoundingSphereZero = { {0.0, 0.0, 0.0}, 0 };

/** Returns a string description of the specified CC3BoundingSphere struct. */
NSString* NSStringFromCC3BoundingSphere(CC3BoundingSphere bb);

/** Returns a CC3BoundingSphere structure constructed from the center coords and radius components. */
CC3BoundingSphere CC3BoundingSphereMake(GLfloat x, GLfloat y, GLfloat z, GLfloat radius);

/** Returns a CC3BoundingSphere structure constructed from the center vector and radius components. */
CC3BoundingSphere CC3BoundingSphereMakeFromCenter(CC3Vector center, GLfloat radius);


/** Unit vector pointing in the same direction as the positive X-axis. */
static const CC3Vector kCC3VectorRight = { 1.0,  0.0,  0.0 };

/** Unit vector pointing in the same direction as the positive Z-axis. */
static const CC3Vector kCC3VectorForward = { 0.0,  0.0,  1.0 };

/** Unit vector pointing in the same direction as the negative Z-axis. */
static const CC3Vector kCC3VectorBackward = { 0.0,  0.0, -1.0 };


@interface CC3GLMatrix (Extension)

/** set the right value of the matrix */
- (void)setRightDirection:(CC3Vector)aVector;

/** set the up value of the matrix */
- (void)setUpDirection:(CC3Vector)aVector;

/** set the backwards value of the matrix */
- (void)setBackwardDirection:(CC3Vector)aVector;

/** set the forward value of the matrix */
- (void)setForwardDirection:(CC3Vector)aVector;

/** set the translation value of the matrix */
- (void)setTranslation:(CC3Vector)aVector;

/** get the translation value of the matrix */
- (CC3Vector)extractTranslation;

@end

@interface NSMutableArray (Matrix)

-(CC3GLMatrix *)matrixAtIndex:(NSUInteger)index;

@end