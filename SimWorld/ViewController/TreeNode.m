//
//  TreeNode.m
//  SimWorld
//
//  Created by Michael Rommel on 08.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeNode.h"

#import "TextureAtlas.h"
#import "TreeProfile.h"
#import "WindStrengthSin.h"
#import "TreeWindAnimator.h"
#import "SimpleTree.h"
#import "Mesh.h"
#import "TreeMesh.h"
#import "TreeLeafCloud.h"

#define PROFILES @[@"Birch", @"Pine", @"Gardenwood", @"Graywood", @"Rug", @"Willow"]

@interface TreeNode() {
    
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    GLuint _depthRenderBuffer;
    
    GLuint _texCoordSlot;
    GLint _samplerArrayLoc;
    
    GLuint _vertexBufferTrunk;
    GLuint _indexBufferTrunk;
    GLuint _vertexBufferLeaves;
    GLuint _indexBufferLeaves;
}

@property (atomic) NSUInteger type;
@property (nonatomic, retain) NSMutableArray *profiles;

@property (nonatomic, retain) WindStrengthSin *wind;
@property (nonatomic, retain) TreeWindAnimator *animator;
@property (nonatomic, retain) SimpleTree *tree;

@end

@implementation TreeNode

- (id)initWithType:(NSUInteger)tree;
{
    self = [super init];
    
    if (self) {
        self.type = tree;
        self.tree = nil;
        
        [self loadTreeGenerators];
        [self setupRenderBuffer];
        [self setupDepthBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        
        glGenBuffers(1, &_vertexBufferTrunk);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTrunk);
        glBufferData(GL_ARRAY_BUFFER, self.tree.trunk.numberOfVertices * sizeof(Vertex), self.tree.trunk.vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indexBufferTrunk);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTrunk);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.tree.trunk.numberOfIndices * sizeof(Index), self.tree.trunk.indices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_vertexBufferLeaves);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferLeaves);
        glBufferData(GL_ARRAY_BUFFER, self.tree.leaves.numberOfVertices * sizeof(Vertex), self.tree.trunk.vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indexBufferLeaves);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferLeaves);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.tree.leaves.numberOfIndices * sizeof(Index), self.tree.trunk.indices, GL_STATIC_DRAW);
    
        self.wind = [[WindStrengthSin alloc] init];
        self.animator = [[TreeWindAnimator alloc] initWithWind:self.wind];
    }
    
    return self;
}

- (void)loadTreeGenerators
{
    self.profiles = [[NSMutableArray alloc] init];
    for (NSString *profileName in PROFILES) {
        NSLog(@"Loading tree: %@", profileName);
        [self.profiles addObject:[[TreeProfile alloc] initWithProfileName:profileName]];
    }
    
    TreeProfile *profile = [self treeProfileAtIndex:self.type];
    self.tree = [profile generateSimpleTree];
    
    NSLog(@"Tree: %@", self.tree);
}

- (TreeProfile *)treeProfileAtIndex:(NSUInteger)index
{
    return [self.profiles objectAtIndex:index];
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupDepthBuffer
{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 200, 200);
}

- (void)setupFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)compileShaders
{
    // 5
    _positionSlot = glGetAttribLocation(self.program.program, "Position");
    _colorSlot = glGetAttribLocation(self.program.program, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _projectionUniform = glGetUniformLocation(self.program.program, "Projection");
    _modelViewUniform = glGetUniformLocation(self.program.program, "Modelview");
    
    _texCoordSlot = glGetAttribLocation(self.program.program, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _samplerArrayLoc = glGetUniformLocation(self.program.program, "texture");
}

+ (REProgram*)program
{
    return [REProgram programWithVertexFilename:@"TreeVertex.glsl"
                               fragmentFilename:@"TreeFragment.glsl"];
}

- (void)draw
{
    [super draw];
    
    glClearColor(100.0/255.0, 149.0/255.0, 237.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glEnable(GL_CULL_FACE);
    glDisable(GL_CULL_FACE);
    //glFrontFace(GL_CW); // GL_CW or GL_CCW
    //glCullFace(GL_BACK); /* GL_FRONT or GL_BACK or even GL_FRONT_AND_BACK */
    
    // Projection Matrix
    const CC3GLMatrix *projectionMatrix = [self.camera projectionMatrix];
    
    // View Matrix
    const CC3GLMatrix *viewMatrix = [self.camera viewMatrix];
    
    // ---------------------------------

    if (self.tree) {
        if (self.showTrunk) {
            [self drawTrunkWithProjection:projectionMatrix andView:viewMatrix];
        }
        if (self.showLeaves) {
            [self drawLeavesWithProjection:projectionMatrix andView:viewMatrix];
        }
    }
}

- (void)drawTrunkWithProjection:(const CC3GLMatrix *)projectionMatrix andView:(const CC3GLMatrix *)viewMatrix
{
    // Bind the trunk texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.tree.trunkTexture);
    
    // we've bound our textures in textures 0.
    const GLint samplers[1] = {0};
    glUniform1iv(_samplerArrayLoc, 1, samplers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTrunk);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTrunk);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.glMatrix);
    glUniformMatrix4fv(_modelViewUniform, 1, 0, viewMatrix.glMatrix);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    //glVertexAttribPointer(_texCoordSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 9));
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    //glEnableVertexAttribArray(_texCoordSlot2);
    
    glDrawElements(GL_TRIANGLES, (int)self.tree.trunk.numberOfIndices, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];
}

- (void)drawLeavesWithProjection:(const CC3GLMatrix *)projectionMatrix andView:(const CC3GLMatrix *)viewMatrix
{
    // Bind the trunk texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.tree.leafTexture);
    
    // we've bound our textures in textures 0.
    const GLint samplers[1] = {0};
    glUniform1iv(_samplerArrayLoc, 1, samplers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferLeaves);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferLeaves);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.glMatrix);
    glUniformMatrix4fv(_modelViewUniform, 1, 0, viewMatrix.glMatrix);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    //glVertexAttribPointer(_texCoordSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 9));
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    //glEnableVertexAttribArray(_texCoordSlot2);
    
    glDrawElements(GL_TRIANGLES, (int)self.tree.leaves.numberOfIndices, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];
}

@end
