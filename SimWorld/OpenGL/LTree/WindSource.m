//
//  WindSource.m
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "WindSource.h"

@implementation WindSource

- (CC3Vector)windStrengthForPosition:(CC3Vector)position
{
    return CC3VectorMake(0, 0, 0);
}

- (void)update
{
    // NOOP
}

@end
