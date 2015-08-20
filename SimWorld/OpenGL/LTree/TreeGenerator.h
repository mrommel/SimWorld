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
