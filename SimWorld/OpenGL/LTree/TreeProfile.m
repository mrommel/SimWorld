//
//  TreeProfile.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeProfile.h"

#import "TreeGenerator.h"
#import "SimpleTree.h"
#import "OpenGLUtil.h"

@implementation TreeProfile

- (id)initWithProfileName:(NSString *)profileName
{
    self = [super init];
    
    if (self) {
        self.generator = [[TreeGenerator alloc] initFromTreeFile:profileName];
        self.trunkTexture = [[OpenGLUtil sharedInstance] setupTexture:self.generator.trunkTextureName];
        self.leafTexture = [[OpenGLUtil sharedInstance] setupTexture:self.generator.leafTextureName];
    }
    
    return self;
}

- (id)initWithTreeGenerator:(TreeGenerator *)generator andTrunkTexture:(GLuint)trunkTexture andLeafTexture:(GLuint)leafTexture
{
    self = [super init];
    
    if (self) {
        self.generator = generator;
        self.trunkTexture = trunkTexture;
        self.leafTexture = leafTexture;
    }
    
    return self;
}

- (SimpleTree *)generateSimpleTree
{
    TreeSkeleton *skeleton = [self.generator generateTree];
    SimpleTree *tree = [[SimpleTree alloc] initWithSkeleton:skeleton];
    tree.trunkTexture = self.trunkTexture;
    tree.leafTexture = self.leafTexture;
    return tree;
}

@end
