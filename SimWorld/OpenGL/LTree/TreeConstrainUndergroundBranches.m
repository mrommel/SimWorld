//
//  TreeConstrainUndergroundBranches.m
//  SimWorld
//
//  Created by Michael Rommel on 31.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeConstrainUndergroundBranches.h"

#import "TreeCrayon.h"
#import "CC3GLMatrix+Extension.h"

@implementation TreeConstrainUndergroundBranches

- (id)init
{
    self = [super init];
    
    if (self) {
        self.limit = 256.0f;
    }
    
    return self;
}

- (id)initWithLimit:(float)limit
{
    self = [super init];
    
    if (self) {
        self.limit = limit;
    }
    
    return self;
}

- (BOOL)constrainForwardWithCrayon:(TreeCrayon *)crayon andDistance:(float *)distance andRadiusEndScale:(float *)radiusEndScale
{
    CC3GLMatrix *m = [crayon transform];
    if ([m extractUpDirection].y < 0.0f && [m extractTranslation].y + [m extractUpDirection].y * *distance < self.limit)
        return NO;// distance *= 100; // Use distance * 100 to visualize which branches will be cut.
    
    return YES;
}

@end
