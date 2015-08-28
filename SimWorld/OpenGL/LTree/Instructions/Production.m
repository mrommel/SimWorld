//
//  Production.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "Production.h"

#import "TreeCrayonInstruction.h"
#import "Debug.h"

#define PRINT_ENABLED

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
    MiRoLog(@"executeCrayon %@", self);
    MiRoLog_Indent();
    for (TreeCrayonInstruction *instruction in self.instructions) {
        [instruction executeCrayon:crayon];
    }
    MiRoLog_Outdent();
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Production name=%@, instructions=%lu]", self.name, (unsigned long)self.instructions.count];
}

@end
