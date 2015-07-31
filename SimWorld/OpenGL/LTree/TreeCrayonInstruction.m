//
//  TreeCrayonInstruction.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCrayonInstruction.h"

#import "TreeCrayon.h"
#import "CC3Math.h"

@implementation TreeCrayonInstruction

- (void)executeCrayon:(TreeCrayon *)crayon
{
    // NOOP
}

@end

@implementation Bone

- (id)initWithDelta:(int)delta
{
    self = [super init];
    
    if (self) {
        self.delta = delta;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    [crayon executeBoneWithDelta:self.delta];
}

@end

@implementation Call

- (id)initWithProductions:(NSArray *)productions andDelta:(int)delta
{
    self = [super init];
    
    if (self) {
        self.delta = delta;
        self.productions = productions;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    NSAssert(self.productions.count > 0, @"No productions exist for call.");
    
    if (crayon.level + self.delta < 0)
        return;
    
    crayon.level = crayon.level+ self.delta;
    
    NSUInteger i = RandomUIntBelow((unsigned int)self.productions.count);
    [[self.productions objectAtIndex:i] executeCrayon:crayon];
    
    crayon.level = crayon.level - self.delta;
}

@end