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

- (id)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.instructions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    NSLog(@"executeCrayon Production with name: %@", self.name);
    for (TreeCrayonInstruction *instruction in self.instructions) {
        [instruction executeCrayon:crayon];
    }
}

@end
