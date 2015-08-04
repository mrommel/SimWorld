//
//  TreeCompositeConstraints.m
//  SimWorld
//
//  Created by Michael Rommel on 31.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCompositeConstraints.h"

@implementation TreeCompositeConstraints

- (id)init
{
    self = [super init];
    
    if (self) {
        self.constaints = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)constrainForwardWithCrayon:(TreeCrayon *)crayon andDistance:(float *)distance andRadiusEndScale:(float *)radiusEndScale
{
    for (TreeContraints *c in self.constaints)
    {
        if (![c constrainForwardWithCrayon:crayon andDistance:distance andRadiusEndScale:radiusEndScale])
            return NO;
    }
    if (self.userConstraint != nil)
        return [self.userConstraint constrainForwardWithCrayon:crayon andDistance:distance andRadiusEndScale:radiusEndScale];
    
    return YES;
}

@end
