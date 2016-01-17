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
#import "TreeSkeleton.h"
#import "TreeAnimationState.h"
#import "NSArray+Extensions.h"
#import "OpenGLUtil.h"

@implementation TreeType

+ (TreeType *)treeWithIdentifier:(int)identifier andName:(NSString *)name
{
    return [[TreeType alloc] initWithIdentifier:identifier andName:name];
}

- (id)initWithIdentifier:(int)identifier andName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        self.identifier = identifier;
        self.name = name;
    }
    
    return self;
}

@end

@interface TreeNode() {
    
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    
    //
    GLuint _positionSlot;
    GLuint _normalSlot;
    GLuint _texCoordSlot;
    GLuint _boneSlot;
    
    GLuint _worldUniform;
    GLuint _viewUniform;
    GLuint _projectionUniform;
    GLuint _bonesUniform00; // 20 bones
    GLuint _bonesUniform01;
    GLuint _bonesUniform02;
    
    // texture
    GLint _samplerArrayLoc;
    
    GLuint _vertexBufferTrunk;
    GLuint _indexBufferTrunk;
    GLuint _vertexBufferLeaves;
    GLuint _indexBufferLeaves;
    
    // quad
    GLuint _vertexBufferQuad;
    GLuint _indexBufferQuad;
}

@property (atomic) NSUInteger type;
@property (nonatomic, retain) NSMutableArray *profiles;

@property (nonatomic, retain) WindStrengthSin *wind;
@property (nonatomic, retain) TreeWindAnimator *animator;
@property (nonatomic, retain) SimpleTree *tree;
@property (atomic) GLuint grassTexture;

@end

@implementation TreeNode

- (id)initWithType:(TreeType *)tree;
{
    self = [super init];
    
    if (self) {
        self.type = tree.identifier;
        self.tree = nil;
        
        [self loadTreeGenerators];
        [self setupRenderBuffer];
        [self setupDepthBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        
        glGenBuffers(1, &_vertexBufferTrunk);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTrunk);
        glBufferData(GL_ARRAY_BUFFER, self.tree.trunk.numberOfVertices * sizeof(TreeVertex), self.tree.trunk.vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indexBufferTrunk);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTrunk);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.tree.trunk.numberOfIndices * sizeof(Index), self.tree.trunk.indices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_vertexBufferLeaves);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferLeaves);
        glBufferData(GL_ARRAY_BUFFER, self.tree.leaves.numberOfVertices * sizeof(Vertex), self.tree.leaves.vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indexBufferLeaves);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferLeaves);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.tree.leaves.numberOfIndices * sizeof(Index), self.tree.leaves.indices, GL_STATIC_DRAW);
    
        self.wind = [[WindStrengthSin alloc] init];
        self.animator = [[TreeWindAnimator alloc] initWithWind:self.wind];
        
        // grass
        self.grassTexture = [[OpenGLUtil sharedInstance] setupTexture:@"Grass.jpg"];
        const TreeVertex quadVertices[] = {
            {{1000, 0, -1000}, {0, 1, 0}, {0, 0}, {0, 0}},
            {{1000, 0, 1000}, {0, 1, 0}, {5, 0}, {0, 0}},
            {{-1000, 0, 1000}, {0, 1, 0}, {0, 5}, {0, 0}},
            {{-1000, 0, -1000}, {0, 1, 0}, {5, 5}, {0, 0}}
        };
        
        glGenBuffers(1, &_vertexBufferQuad);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferQuad);
        glBufferData(GL_ARRAY_BUFFER, 4 * sizeof(TreeVertex), quadVertices, GL_STATIC_DRAW);
        
        const Index quadIndices[] = {
            0, 2, 1,
            2, 0, 3
        };
        glGenBuffers(1, &_indexBufferQuad);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferQuad);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(Index), quadIndices, GL_STATIC_DRAW);
    }
    
    return self;
}

- (void)loadTreeGenerators
{
    self.profiles = [[NSMutableArray alloc] init];
    for (TreeType *treeType in TREE_TYPES) {
        NSLog(@"Loading tree: %@", treeType.name);
        [self.profiles addObject:[[TreeProfile alloc] initWithProfileName:treeType.name]];
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
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)compileShaders
{
    // 5
    _positionSlot = glGetAttribLocation(self.program.program, "Position");
    glEnableVertexAttribArray(_positionSlot);
    _normalSlot = glGetAttribLocation(self.program.program, "Normal");
    glEnableVertexAttribArray(_normalSlot);
    _texCoordSlot = glGetAttribLocation(self.program.program, "TexCoordIn");
    glEnableVertexAttribArray(_texCoordSlot);
    _boneSlot = glGetAttribLocation(self.program.program, "BoneIndex");
    glEnableVertexAttribArray(_boneSlot);
    
    /*for( int i = 0; i < 20; i++) {
        NSString *boneString = [NSString stringWithFormat:@"Bones[%d]", i];
        _bonesUniform[i] = glGetUniformLocation(self.program.program, [boneString UTF8String]);
    }*/
    _bonesUniform00 = glGetUniformLocation(self.program.program, [@"Bones00" UTF8String]);
    _bonesUniform01 = glGetUniformLocation(self.program.program, [@"Bones01" UTF8String]);
    _bonesUniform02 = glGetUniformLocation(self.program.program, [@"Bones02" UTF8String]);
    
    _worldUniform = glGetUniformLocation(self.program.program, "World");
    _viewUniform = glGetUniformLocation(self.program.program, "View");
    _projectionUniform = glGetUniformLocation(self.program.program, "Projection");
    
    _samplerArrayLoc = glGetUniformLocation(self.program.program, "texture");
}

+ (REProgram*)program
{
    return [REProgram programWithVertexFilename:@"TreeVertex2.glsl"
                               fragmentFilename:@"TreeFragment.glsl"];
}

- (void)draw
{
    [super draw];
    
    glClearColor(100.0/255.0, 149.0/255.0, 237.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glDisable(GL_CULL_FACE);
    glDisable(GL_CULL_FACE); // to see both sides of the trianlges
    //glEnable(GL_CULL_FACE);
    //glFrontFace(GL_CCW); // GL_CW or GL_CCW
    //glCullFace(GL_FRONT_AND_BACK); /* GL_FRONT or GL_BACK or even GL_FRONT_AND_BACK */
    
    // Projection Matrix
    const CC3GLMatrix *projectionMatrix = [self.camera projectionMatrix];
    
    // View Matrix
    const CC3GLMatrix *viewMatrix = [self.camera viewMatrix];
    
    // ---------------------------------
    [self drawGrassWithProjection:projectionMatrix andView:viewMatrix];

    if (self.tree) {
        if (self.showTrunk) {
            [self drawTrunkWithProjection:projectionMatrix andView:viewMatrix];
        }
        if (self.showLeaves) {
            [self drawLeavesWithProjection:projectionMatrix andView:viewMatrix];
        }
    }
}

- (void)drawGrassWithProjection:(const CC3GLMatrix *)projectionMatrix andView:(const CC3GLMatrix *)viewMatrix
{
    // Bind the trunk texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.grassTexture);
    
    // we've bound our textures in textures 0.
    const GLint samplers[1] = {0};
    glUniform1iv(_samplerArrayLoc, 1, samplers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferQuad);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferQuad);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.glMatrix );
    glUniformMatrix4fv(_viewUniform, 1, 0, viewMatrix.glMatrix);
    glUniformMatrix4fv(_worldUniform, 1, 0, [self transformMatrix].glMatrix);
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (0 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_normalSlot);
    glVertexAttribPointer(_normalSlot, 3, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_texCoordSlot);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_boneSlot);
    glVertexAttribPointer(_boneSlot, 2, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (8 * sizeof(GLfloat)));
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];
}

- (void)drawTrunkWithProjection:(const CC3GLMatrix *)projectionMatrix andView:(const CC3GLMatrix *)viewMatrix
{
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // Bind the trunk texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.tree.trunkTexture);
    
    // we've bound our textures in textures 0.
    const GLint samplers[1] = {0};
    glUniform1iv(_samplerArrayLoc, 1, samplers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTrunk);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTrunk);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.glMatrix );
    glUniformMatrix4fv(_viewUniform, 1, 0, viewMatrix.glMatrix);
    glUniformMatrix4fv(_worldUniform, 1, 0, [self transformMatrix].glMatrix);
    
    /*NSLog(@"Projection: %@", projectionMatrix);
    NSLog(@"View: %@", viewMatrix);
    NSLog(@"World: %@", [self transformMatrix]);*/
    
    // TODO: do it only once
    if (self.tree.bindingMatrices.count != self.tree.skeleton.bones.count) {
        NSUInteger numberOfItems = self.tree.skeleton.bones.count;
        self.tree.bindingMatrices = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
        [self.tree.bindingMatrices fillWith:[CC3GLMatrix matrix] forAmount:numberOfItems];
    }
    [self.tree.skeleton copyAbsoluteBoneTranformsTo:self.tree.bindingMatrices andBoneRotation:self.tree.animationState.rotations];

    // Passing 20 matrices
    /*for (int i = 0; i < self.tree.bindingMatrices.count; i++) {
        glUniformMatrix4fv(_bonesUniform[i], 1, false, [self.tree.bindingMatrices matrixAtIndex:i].glMatrix);
        //identify glUniformMatrix4fv(_bonesUniform[i], 1, false, [CC3GLMatrix identity].glMatrix);
    }*/
    glUniformMatrix4fv(_bonesUniform00, 1, false, [self.tree.bindingMatrices matrixAtIndex:0].glMatrix);
    glUniformMatrix4fv(_bonesUniform01, 1, false, [self.tree.bindingMatrices matrixAtIndex:1].glMatrix);
    glUniformMatrix4fv(_bonesUniform02, 1, false, [self.tree.bindingMatrices matrixAtIndex:2].glMatrix);
    
    // Debug
    // gl_Position = Projection * View * World * Bones[int(BoneIndex.x)] * Position;
    /*TreeVertex firstVertex = self.tree.trunk.vertices[0];
    CC3Vector tmpPosition = CC3VectorMake(firstVertex.Position[0], firstVertex.Position[1], firstVertex.Position[2]);
    CC3Vector tmp1 = [[self.tree.bindingMatrices matrixAtIndex:(firstVertex.Bones[0])] transformDirection:tmpPosition];
    CC3Vector tmp2 = [viewMatrix transformDirection:tmp1];
    CC3Vector tmp3 = [projectionMatrix transformDirection:tmp2];*/
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (0 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_normalSlot);
    glVertexAttribPointer(_normalSlot, 4, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_texCoordSlot);
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(_boneSlot);
    glVertexAttribPointer(_boneSlot, 2, GL_FLOAT, GL_FALSE, sizeof(TreeVertex), (GLvoid*) (8 * sizeof(GLfloat)));
    
    //glDrawElements(GL_TRIANGLES, (int)self.tree.trunk.numberOfIndices, GL_UNSIGNED_INT, 0);
    glDrawElements(GL_TRIANGLES, (int)27, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];
}

- (void)drawLeavesWithProjection:(const CC3GLMatrix *)projectionMatrix andView:(const CC3GLMatrix *)viewMatrix
{
    return;
    /*// Bind the trunk texture
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
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    
    glDrawElements(GL_TRIANGLES, (int)self.tree.leaves.numberOfIndices, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];*/
}

@end
