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

#define PROFILES @[@"Birch", @"Pine", @"Gardenwood", @"Graywood", @"Rug", @"Willow"]

@interface TreeNode() {
    
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    GLuint _depthRenderBuffer;
    
    GLuint _texCoordSlot;
    GLuint _texCoordSlot2;
    GLint _samplerArrayLoc;
    
    GLuint _vertexBufferTerrains;
    GLuint _indexBufferTerrains;
}

@property (atomic) TreeType type;
@property (nonatomic, retain) NSMutableArray *profiles;
@property (nonatomic, retain) WindStrengthSin *wind;
@property (nonatomic, retain) TreeWindAnimator *animator;

@end

@implementation TreeNode

- (id)initWithType:(TreeType)type
{
    self = [super init];
    
    if (self) {
        self.type = type;
        
        self.wind = [[WindStrengthSin alloc] init];
        self.animator = [[TreeWindAnimator alloc] initWithWind:self.wind];
        
        [self loadTreeGenerators];
        [self setupRenderBuffer];
        [self setupDepthBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
    }
    
    return self;
}

- (void)loadTreeGenerators
{
    self.profiles = [[NSMutableArray alloc] init];
    for (NSString *profileName in PROFILES) {
        [self.profiles addObject:[[TreeProfile alloc] initWithProfileName:profileName]];
    }
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupDepthBuffer {
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

- (void)setupVBOs
{
    /*TextureAtlas *textureAtlas = [[TextureAtlas alloc] initWithAtlasFileName:@"terrains"];
    TextureAtlas *riverAtlas = [[TextureAtlas alloc] initWithAtlasFileName:@"rivers"];
    _terrainMesh = [[HexagonMapMesh alloc] initWithMap:self.map andTerrainAtlas:textureAtlas andRiverAtlas:riverAtlas];
    
    glGenBuffers(1, &_vertexBufferTerrains);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTerrains);
    glBufferData(GL_ARRAY_BUFFER, _terrainMesh.numberOfVertices * sizeof(Vertex), _terrainMesh.vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBufferTerrains);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTerrains);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, _terrainMesh.numberOfIndices * sizeof(Index), _terrainMesh.indices, GL_STATIC_DRAW);*/
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
    _texCoordSlot2 = glGetAttribLocation(self.program.program, "TexCoordIn2");
    glEnableVertexAttribArray(_texCoordSlot2);
    _samplerArrayLoc = glGetUniformLocation(self.program.program, "texture");
}

+ (REProgram*)program
{
    return [REProgram programWithVertexFilename:@"SimpleVertex.glsl"
                               fragmentFilename:@"SimpleFragment.glsl"];
}

- (void)draw
{
    [super draw];
    
    glClearColor(0.0/255.0, 20.0/255.0, 0.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    glEnable (GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Projection Matrix
    const CC3GLMatrix *projectionMatrix = [self.camera projectionMatrix];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix.glMatrix);
    
    // View Matrix
    const CC3GLMatrix *viewMatrix = [self.camera viewMatrix];
    
    // ---------------------------------
    
    // Bind the base map
    /*
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _terrainMesh.texture);
    
    // we've bound our textures in textures 0.
    const GLint samplers[1] = {0};
    glUniform1iv(_samplerArrayLoc, 1, samplers);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferTerrains);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBufferTerrains);
    
    glUniformMatrix4fv(_modelViewUniform, 1, 0, viewMatrix.glMatrix);
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    glVertexAttribPointer(_texCoordSlot2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 9));
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    glEnableVertexAttribArray(_texCoordSlot2);
    
    glDrawElements(GL_TRIANGLES, _terrainMesh.numberOfIndices, GL_UNSIGNED_INT, 0);
    
    // unbind textures
    [RETexture unbind];*/
}

@end
