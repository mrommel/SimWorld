//
//  MiRoStack.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiRoStack : NSObject <NSFastEnumeration>

@property (nonatomic, assign, readonly) NSUInteger count;

- (id)initWithArray:(NSArray*)array;

- (void)pushObject:(id)object;
- (void)pushObjects:(NSArray*)objects;
- (id)popObject;
- (id)peekObject;

@end
