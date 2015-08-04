//
//  CC3GLMatrix+Extension.m
//  SimWorld
//
//  Created by Michael Rommel on 15.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "CC3GLMatrix+Extension.h"

#pragma mark -
#pragma mark vector 2D structure and functions

CC2Vector CC2VectorMake(GLfloat x, GLfloat y)
{
    CC2Vector v;
    v.x = x;
    v.y = y;
    return v;
}

CC2Vector CC2VectorScaleUniform(CC2Vector v, GLfloat scale)
{
    CC2Vector result;
    result.x = v.x * scale;
    result.y = v.y * scale;
    return result;
}

GLfloat CC2VectorLength(CC2Vector v)
{
    return sqrtf(v.x * v.x + v.y * v.y);
}

#pragma mark -
#pragma mark Bounding sphere structure and functions

NSString* NSStringFromCC3BoundingSphere(CC3BoundingSphere bb)
{
    return [NSString stringWithFormat: @"(Center: %@, radius: %f)",
            NSStringFromCC3Vector(bb.center), bb.radius];
}

CC3BoundingSphere CC3BoundingSphereMake(GLfloat x, GLfloat y, GLfloat z, GLfloat radius)
{
    CC3BoundingSphere sphere;
    sphere.center = CC3VectorMake(x, y, z);
    sphere.radius = radius;
    return sphere;
}

CC3BoundingSphere CC3BoundingSphereMakeFromCenter(CC3Vector center, GLfloat radius)
{
    CC3BoundingSphere sphere;
    sphere.center = center;
    sphere.radius = radius;
    return sphere;
}

#pragma mark -
#pragma mark CC3GLMatrix structure and functions

// zero based (4x4)
// m00 => 0
// m10 => 1
// m20 => 2
// m30 => 3

// m01 => 4
// m11 => 5
// m21 => 6
// m31 => 7

// m02 => 8
// m12 => 9
// m22 => 10
// m32 => 11

// m03 => 12
// m13 => 13
// m23 => 14
// m33 => 15

// one based (3x3)
// m11 => 0
// m21 => 1
// m31 => 2
// m12 => 3

@implementation CC3GLMatrix (Extension)

- (void)setRightDirection:(CC3Vector)aVector
{
    /*
            | x  0  0  0 |
     M =    | y  1  0  0 |
            | z  0  1  0 |
            | 0  0  0  1 |
     */
    GLfloat* m = self.glMatrix;
    m[0] = aVector.x;
    m[1] = aVector.y;
    m[2] = aVector.z;
}

- (void)setUpDirection:(CC3Vector)aVector
{
    /*
            | 1  x  0  0 |
     M =    | 0  y  0  0 |
            | 0  z  1  0 |
            | 0  0  0  1 |
     */
    GLfloat* m = self.glMatrix;
    m[4] = aVector.x;
    m[5] = aVector.y;
    m[6] = aVector.z;
}

- (void)setBackwardDirection:(CC3Vector)aVector
{
    /*
            | 1  0  x  0 |
     M =    | 0  1  y  0 |
            | 0  0  z  0 |
            | 0  0  0  1 |
     */
    GLfloat* m = self.glMatrix;
    m[8] = aVector.x;
    m[9] = aVector.y;
    m[10] = aVector.z;
}

- (void)setForwardDirection:(CC3Vector)aVector
{
    /*
            | 1  0  -x  0 |
     M =    | 0  1  -y  0 |
            | 0  0  -z  0 |
            | 0  0  0  1 |
     */
    GLfloat* m = self.glMatrix;
    m[8] = -aVector.x;
    m[9] = -aVector.y;
    m[10] = -aVector.z;
}

- (void)setTranslation:(CC3Vector)aVector
{
    /*
            | 1  0  0  x |
     M =    | 0  1  0  y |
            | 0  0  1  z |
            | 0  0  0  1 |
     */
    GLfloat* m = self.glMatrix;
    m[12] = aVector.x;
    m[13] = aVector.y;
    m[14] = aVector.z;
}

- (void)setTranslationY:(float)y
{
    GLfloat* m = self.glMatrix;
    m[13] = y;
}

- (CC3Vector)extractTranslation
{
    GLfloat* m = self.glMatrix;
    return CC3VectorMake(m[12], m[13], m[14]);
}

- (CC3Vector)transformNormal:(CC3Vector)normal
{
    GLfloat* m = self.glMatrix;
    CC3Vector vector;
    vector.x = normal.x * m[0] + normal.y * m[1] + normal.z * m[2];
    vector.y = normal.x * m[3] + normal.y * m[4] + normal.z * m[5];
    vector.z = normal.x * m[6] + normal.y * m[7] + normal.z * m[8];
    return vector;
}

- (CC3GLMatrix *)copyInverted
{
    CC3GLMatrix *result = [CC3GLMatrix matrix];
    [result populateFrom:self];
    [result invert];
    
    return result;
}

- (CC3GLMatrix *)copyMultipliedBy:(CC3GLMatrix *)mut
{
    CC3GLMatrix *result = [CC3GLMatrix matrix];
    [result populateFrom:self];
    [result multiplyByMatrix:mut];
    
    return result;
}

+ (CC3GLMatrix *)matrixFromQuaternion:(CC3Vector4)quaternion
{
    CC3GLMatrix *mat = [CC3GLMatrix matrix];
    [mat populateFromQuaternion:quaternion];
    return mat;
}

@end

@implementation NSMutableArray (Matrix)

- (CC3GLMatrix *)matrixAtIndex:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

- (void)addMatrix:(CC3GLMatrix *)matrix
{
    [self addObject:matrix];
}

- (void)insertMatrix:(CC3GLMatrix *)matrix atIndex:(NSUInteger)index
{
    [self insertObject:matrix atIndex:index];
}

- (void)addVector4:(CC3Vector4)vector
{
    NSValue *boxedVector = [NSValue valueWithBytes:&vector objCType:@encode(CC3Vector4)];
    [self addObject:boxedVector];
}

- (void)insertVector4:(CC3Vector4)vector atIndex:(NSUInteger)index
{
    NSValue *boxedVector = [NSValue valueWithBytes:&vector objCType:@encode(CC3Vector4)];
    [self insertObject:boxedVector atIndex:index];
}

- (CC3Vector4)vector4AtIndex:(NSUInteger)index
{
    CC3Vector4 vector;
    
    NSValue *boxedVector = [self objectAtIndex:index];
    if (strcmp([boxedVector objCType], @encode(CC3Vector4)) == 0) {
        [boxedVector getValue:&vector];
        return vector;
    }
    
    return kCC3Vector4Zero;
}

@end

@implementation CC3GLVector

- (id)initWithVector:(CC3Vector)vector
{
    self = [super init];
    
    if (self) {
        self.value = vector;
    }
    
    return self;
}

@end
