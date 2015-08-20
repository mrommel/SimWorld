//
//  NSArray+Extensions.m
//  SimWorld
//
//  Created by Michael Rommel on 14.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSMutableArray (Extensions)

- (void)fillWith:(id)obj andTimes:(int)amount
{
    for (int i = 0; i < amount; i++) {
        [self addObject:obj];
    }
}

- (void)fillWithFloat:(float)obj andTimes:(int)amount
{
    for (int i = 0; i < amount; i++) {
        [self addObject:[NSNumber numberWithFloat:obj]];
    }
}

@end

@implementation NSArray (Extensions)

- (float)floatAtIndex:(int)index
{
    return [[self objectAtIndex:index] floatValue];
}

@end
