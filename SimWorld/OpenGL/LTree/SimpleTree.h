//
//  SimpleTree.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeLeafCloud;
@class TreeMesh;
@class TreeSkeleton;
@class TreeAnimationState;

@interface SimpleTree : NSObject

@property (nonatomic, retain) TreeLeafCloud *leaves;
@property (nonatomic, retain) TreeMesh *trunk;
@property (nonatomic, retain) TreeSkeleton *skeleton;
@property (nonatomic, retain) TreeAnimationState *animationState;
@property (atomic) GLuint trunkTexture;
@property (atomic) GLuint leafTexture;
@property (nonatomic, retain) NSMutableArray *bindingMatrices;

- (id)initWithSkeleton:(TreeSkeleton *)skeleton;

@end
