//
//  Production.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "Production.h"

#import "TreeCrayonInstruction.h"

@implementation Production

- (id)init
{
    self = [super init];
    
    if (self) {
        self.instructions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    for (TreeCrayonInstruction *instruction in self.instructions) {
        [instruction executeCrayon:crayon];
    }
}

@end
