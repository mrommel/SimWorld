//
//  NSArray+Extensions.m
//  SimWorld
//
//  Created by Michael Rommel on 14.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (float)floatAtIndex:(int)index
{
    return [[self objectAtIndex:index] floatValue];
}

@end
