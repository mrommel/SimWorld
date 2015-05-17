//
//  Mesh.h
//  SimWorld
//
//  Created by Michael Rommel on 14.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <OpenGLES/ES2/gl.h>

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
    float TexCoord2[2];
} Vertex;

typedef unsigned int Index;

@interface Mesh : NSObject

@property (nonatomic, assign) Vertex* vertices;
@property (nonatomic, assign) int numberOfVertices;
@property (nonatomic, assign) Index* indices;
@property (nonatomic, assign) int numberOfIndices;
@property (nonatomic, assign) GLuint texture;

- (id)initWithNumberOfVertices:(int)numberOfVertices
            andNumberOfIndices:(int)numberOfIndices
                    andTexture:(GLuint)texture;

- (id)initWithNumberOfVertices:(int)numberOfVertices
            andNumberOfIndices:(int)numberOfIndices
                andTextureFile:(NSString *)textureFile;

- (void)setVertexAt:(int)index
               andX:(float)x andY:(float)y andZ:(float)z
        andTextureX:(float)tx andTextureY:(float)ty;

- (void)setVertexAt:(int)index
               andX:(float)x andY:(float)y andZ:(float)z
        andTextureX:(float)tx andTextureY:(float)ty
       andTextureX2:(float)tx2 andTextureY2:(float)ty2;
- (void)setTriangleAt:(int)index withIndex1:(int)i1 andIndex2:(int)i2 andIndex3:(int)i3;

- (void)moveWithX:(float)dx andY:(float)dy andZ:(float)dz;

@end
