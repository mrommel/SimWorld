//
//  TeapotNode.m
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "TeapotNode.h"

@implementation TeapotNode

+ (REProgram*)program
{
    return [REProgram programWithVertexFilename:@"sFragmentLighting.vsh" fragmentFilename:@"sFragmentLighting.fsh"];
}

- (id)initWithDefaultMesh:(REWavefrontMesh*)mesh
{
    self = [super initWithDefaultMesh:mesh];
    
    if (self) {
        self.rotationAxis = CC3VectorMake(0.1, 1, 0.3);
        self.material.ambient = CC3Vector4Make(0.3, 0.3, 0.3, 1.0);
        self.material.diffuse = CC3Vector4Make(0.4, 0.2, 0.2, 1.0);
        self.material.specular = CC3Vector4Make(0.5, 0.6, 0.5, 1.0);
        self.material.shininess = 24;
    }
    
    return self;
}

@end
