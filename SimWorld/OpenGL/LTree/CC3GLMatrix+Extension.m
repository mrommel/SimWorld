//
//  CC3GLMatrix+Extension.m
//  SimWorld
//
//  Created by Michael Rommel on 15.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "CC3GLMatrix+Extension.h"

CC2Vector CC2VectorMake(GLfloat x, GLfloat y) {
    CC2Vector v;
    v.x = x;
    v.y = y;
    return v;
}

@implementation CC3GLMatrix (Extension)

- (void)setRightDirection:(CC3Vector) aVector
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

- (void)setUpDirection:(CC3Vector) aVector
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

- (void)setBackwardDirection:(CC3Vector) aVector
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

- (void)setForwardDirection:(CC3Vector) aVector
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

- (void)setTranslation:(CC3Vector) aVector
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

- (CC3Vector)extractTranslation
{
    GLfloat* m = self.glMatrix;
    return CC3VectorMake(m[12], m[13], m[14]);
}

@end
