//
//  TreeCrayon.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCrayon.h"

#import "MiRoStack.h"
#import "TreeSkeleton.h"
#import "TreeContraints.h"
#import "CC3GLMatrix.h"

@interface TreeCrayonState : NSObject

@property (atomic) int parentIndex;
@property (atomic) float parentPosition;
@property (atomic) float scale;
@property (nonatomic, retain) CC3GLMatrix *rotation;
@property (atomic) int level;
@property (atomic) float radiusScale;
@property (atomic) int parentBoneIndex;
@property (atomic) int boneLevel;

@end

@interface TreeCrayon() {
    
}

@property (nonatomic, retain) TreeCrayonState *state;
@property (nonatomic, retain) MiRoStack *stack;
@property (nonatomic, retain) TreeSkeleton *skeleton;
@property (nonatomic, retain) NSMutableArray *branchTransforms; // Matrix
@property (nonatomic, retain) NSMutableArray *boneEndings; // Map from bone index to branch where it was created // int

@property (nonatomic, retain) TreeContraints *constraints;

@property (atomic) int boneLevels; // = 3;

#define MaxBones 20;

@end

@implementation TreeCrayon

- (id)init
{
    self = [super init];
    
    if (self) {
        self.state = [[TreeCrayonState alloc] init];
        self.state.parentIndex = -1;
        self.state.parentPosition = 1.0f;
        self.state.scale = 1.0f;
        self.state.rotation = [[CC3GLMatrix alloc] initIdentity];
        self.state.level = 1;
        self.state.radiusScale = 1.0f;
        self.state.parentBoneIndex = -1;
        self.state.boneLevel = 0;
    }
    
    return self;
}

@end
