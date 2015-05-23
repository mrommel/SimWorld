//
//  HouseNode.m
//  SimWorld
//
//  Created by Michael Rommel on 25.01.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "HouseNode.h"

@implementation HouseNode

+ (REProgram*)program
{
    return [REProgram programWithVertexFilename:@"sFragmentLighting.vsh" fragmentFilename:@"sFragmentLighting.fsh"];
}

- (id)init
{
    self = [super initWithDefaultMesh:[REMeshCache meshNamed:@"RuralStall.obj"]];
    
    if (self) {
        self.rotationAxis = CC3VectorMake(0.1, -1, 0.3);
        self.material.ambient = CC3Vector4Make(0.3, 0.3, 0.3, 1.0);
        self.material.diffuse = CC3Vector4Make(0.4, 0.2, 0.2, 1.0);
        self.material.specular = CC3Vector4Make(0.5, 0.6, 0.5, 1.0);
        self.material.shininess = 24;
        
        //self.texture = [RETextureCache textureNamed:@"RuralStallBaseExc_Diffuce.jpg"];
    }
    
    return self;
}

// Overrides draw to set own array of mv/p-matrices
- (void)draw
{
    [super draw];
    
    // SHARED DATA
    REProgram *p = self.program;
    
    // World
    REWorld *world = self.world;
    
    NSArray *directionalLights = [world lightsOfClass:[REDirectionalLight class]];
    
    glUniform4f([p uniformLocation:@"u_material.ambientFactor"], material_.ambient.x, material_.ambient.y, material_.ambient.z, material_.ambient.w);
    glUniform4f([p uniformLocation:@"u_material.diffuseFactor"], material_.diffuse.x, material_.diffuse.y, material_.diffuse.z, material_.diffuse.w);
    glUniform4f([p uniformLocation:@"u_material.specularFactor"], material_.specular.x, material_.specular.y, material_.specular.z, material_.specular.w);
    glUniform1f([p uniformLocation:@"u_material.shininess"], material_.shininess);
    
    NSUInteger directionalLightCount = [directionalLights count];
    glUniform1f([p uniformLocation:@"u_directionalLightCount"], directionalLightCount);
    
    glUniform1f([p uniformLocation:@"u_alpha"], [self.alpha floatValue]);
    
    // Populate lights
    for (int i = 0; i < directionalLightCount; i++) {
        REDirectionalLight *light = [directionalLights objectAtIndex:i];
        
        NSString *uniformDirection = nil;
        NSString *uniformHalfplane = nil;
        NSString *uniformAmbientColor = nil;
        NSString *uniformDiffuseColor = nil;
        NSString *uniformSpecularColor = nil;
        
        // Avoid generating strings dynamically for speed reasons. Can make a big difference (like 20% of total execution time).
        if (i == 0) {
            uniformDirection = @"u_directionalLight.direction";
            uniformHalfplane = @"u_directionalLight.halfplane";
            uniformAmbientColor = @"u_directionalLight.ambientColor";
            uniformDiffuseColor = @"u_directionalLight.diffuseColor";
            uniformSpecularColor = @"u_directionalLight.specularColor";
        }
        
        if (i == 1) {
            uniformDirection = @"u_directionalLight1.direction";
            uniformHalfplane = @"u_directionalLight1.halfplane";
            uniformAmbientColor = @"u_directionalLight1.ambientColor";
            uniformDiffuseColor = @"u_directionalLight1.diffuseColor";
            uniformSpecularColor = @"u_directionalLight1.specularColor";
        }
        
        // Creating strings dynamically, seems to be potentially _very_ slow. ex:
        // NSString *s = [NSString stringWithFormat:@"u_directionalLight%d.", i];
        // [s stringByAppendingFormat:@"direction"]
        GLint u_directionalLightDirection = [p uniformLocation:uniformDirection];
        GLint u_directionalLightHalfplane = [p uniformLocation:uniformHalfplane];
        GLint u_directionalLightAmbientColor = [p uniformLocation:uniformAmbientColor];
        GLint u_directionalLightDiffuseColor = [p uniformLocation:uniformDiffuseColor];
        GLint u_directionalLightSpecularColor = [p uniformLocation:uniformSpecularColor];
        
        CC3Vector halfplane = CC3VectorNormalize(CC3VectorAdd(CC3VectorNormalize(light.position), CC3VectorMake(0, 0, 1)));
        
        // We're sending position to direction. This is from OpenGL ES 2.0 programming guide p.161. This
        // seem to be valid because light (and viewer) is at infinity. position.x = 0; And they don't negate it.
        CC3Vector normalizedDirection = CC3VectorNormalize(light.direction);
        glUniform3f(u_directionalLightDirection, normalizedDirection.x, normalizedDirection.y, normalizedDirection.z);
        glUniform3f(u_directionalLightHalfplane, halfplane.x, halfplane.y, halfplane.z);
        
        glUniform4f(u_directionalLightAmbientColor, light.ambientColor.x, light.ambientColor.y, light.ambientColor.z, light.ambientColor.w);
        glUniform4f(u_directionalLightDiffuseColor, light.diffuseColor.x, light.diffuseColor.y, light.diffuseColor.z, light.diffuseColor.w);
        glUniform4f(u_directionalLightSpecularColor, light.specularColor.x, light.specularColor.y, light.specularColor.z, light.specularColor.w);
    }
    
    for (NSString *group in wavefrontMeshA_.groups) {
        NSLog(@"Render group %@", group);
        REWavefrontElementSet *elementSet = [wavefrontMeshA_ elementsForGroup:group];
        //NSLog(@"Render group %@", elementSet.material);
    }

    // Bind texture and environment map
    glUniform1i([p uniformLocation:@"s_texture"], 0);
    
    [texture bind:GL_TEXTURE0];
    
    REWavefrontVertexAttributes *attributesA = wavefrontMeshA_.vertexAttributes;
    
    [REBuffer unbind];
    
    if ([wavefrontMeshA_ hasBuffers])
        [wavefrontMeshA_ bindBuffers];
    
    GLint a_positionA = [p attribLocation:@"a_position"];
    GLint a_normalA = [p attribLocation:@"a_normal"];
    GLint a_texCoord = [p attribLocation:@"a_texCoord"];
    
    // Disable just for safety
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    glDisableVertexAttribArray(3);
    glDisableVertexAttribArray(4);
    
    glVertexAttribPointer(a_positionA, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, vertex));
    glEnableVertexAttribArray(a_positionA);
    
    if (a_normalA >= 0) {
        glVertexAttribPointer(a_normalA, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, normal));
        glEnableVertexAttribArray(a_normalA);
    }
    
    if (a_texCoord >= 0) {
        glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, texCoord));
        glEnableVertexAttribArray(a_texCoord);
    }
    
    glDrawElements(GL_TRIANGLES, (GLsizei)wavefrontMeshA_.elementIndexCount, GL_UNSIGNED_SHORT, 0);
    
    [RETexture unbind];
}

@end
