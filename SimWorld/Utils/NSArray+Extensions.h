//
//  NSArray+Extensions.h
//  SimWorld
//
//  Created by Michael Rommel on 14.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TreeVertex.h"

@interface NSMutableArray (Extensions)

- (void)fillWith:(id)obj forAmount:(NSInteger)amount;
- (void)fillWithFloat:(float)obj forAmount:(NSInteger)amount;

- (void)addTreeVertex:(TreeVertex)treeVertex;
- (TreeVertex)treeVertexAtIndex:(int)index;

@end

@interface NSArray (Extensions)

- (float)floatAtIndex:(int)index;
- (int)intAtIndex:(int)index;

@end
