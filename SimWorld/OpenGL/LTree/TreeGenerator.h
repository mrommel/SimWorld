//
//  TreeGenerator.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeSkeleton;
@class Production;
@class TreeContraints;

/// <summary>
/// Randomly generates tree skeletons using an L-system. It is recommended to load this from an XML file using <see cref="CreateFromXML"/>.
/// </summary>
/// <remarks>
/// This class only produces tree skeletons, which by themselves cannot be rendered. Use the <see cref="TreeMesh"/> and <see cref="TreeLeafCloud"/>
/// classes to generate meshes and particles that can be rendered. The <see cref="SimpleTree"/> class can do this for you that can be used in
/// most simple applications.
/// </remarks>
@interface TreeGenerator : NSObject

@property (atomic) CC3Vector leafAxis;
@property (atomic) int maxLevel;
@property (atomic) int boneLevels;
@property (nonatomic, retain) Production *root;
@property (nonatomic, retain) NSString *trunkTextureName;
@property (nonatomic, retain) NSString *leafTextureName;

- (id)initFromTreeFile:(NSString *)ltreeFilename;

- (TreeSkeleton *)generateTree;
- (TreeSkeleton *)generateTreeWithContraints:(TreeContraints *)userConstraint;

@end
