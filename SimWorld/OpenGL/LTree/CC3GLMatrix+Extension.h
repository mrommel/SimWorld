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

@interface CC3GLMatrix (Extension)

- (void)setRightDirection:(CC3Vector) aVector;
- (void)setUpDirection:(CC3Vector) aVector;
- (void)setBackwardDirection:(CC3Vector) aVector;
- (void)setForwardDirection:(CC3Vector) aVector;

- (void)setTranslation:(CC3Vector) aVector;
- (CC3Vector)extractTranslation;

@end
