//
//  NSArray+Extensions.h
//  SimWorld
//
//  Created by Michael Rommel on 14.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Extensions)

- (void)fillWith:(id)obj andTimes:(NSInteger)amount;
- (void)fillWithFloat:(float)obj andTimes:(int)amount;

@end

@interface NSArray (Extensions)

- (float)floatAtIndex:(int)index;

@end
