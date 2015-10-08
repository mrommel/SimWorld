//
//  NSArray+Extensions.m
//  SimWorld
//
//  Created by Michael Rommel on 14.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSMutableArray (Extensions)

- (void)fillWith:(id)obj forAmount:(NSInteger)amount
{
    for (int i = 0; i < amount; i++) {
        [self addObject:obj];
    }
}

- (void)fillWithFloat:(float)obj forAmount:(NSInteger)amount
{
    for (int i = 0; i < amount; i++) {
        [self addObject:[NSNumber numberWithFloat:obj]];
    }
}

- (void)addTreeVertex:(TreeVertex)treeVertex
{
    NSValue *boxedVector = [NSValue valueWithBytes:&treeVertex objCType:@encode(TreeVertex)];
    [self addObject:boxedVector];
}

- (TreeVertex)treeVertexAtIndex:(int)index
{
    TreeVertex treeVertex;
    
    NSValue *boxedVector = [self objectAtIndex:index];
    if (strcmp([boxedVector objCType], @encode(TreeVertex)) == 0) {
        [boxedVector getValue:&treeVertex];
        return treeVertex;
    }
    
    return kTreeVertexZero;
}

@end

@implementation NSArray (Extensions)

- (float)floatAtIndex:(int)index
{
    return [[self objectAtIndex:index] floatValue];
}

- (int)intAtIndex:(int)index
{
    return [[self objectAtIndex:index] intValue];
}

@end
