//
//  HexRiver.m
//  SimWorld
//
//  Created by Michael Rommel on 01.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexRiver.h"

#import "NSString+TSStyle.h"

@interface HexRiver() {
    
}

@property (atomic, assign) int river;

@end

@implementation HexRiver

- (id)initWithNumber:(int)riverVal
{
    self = [super init];
    
    if (self) {
        self.river = riverVal;
    }
    
    return self;
}

- (BOOL)isWOfRiver
{
    if ((self.river & FLOWDIRECTION_NORTH_MASK) > 0)
        return YES;
    
    if ((self.river & FLOWDIRECTION_SOUTH_MASK) > 0)
        return YES;
    
    return NO;
}

- (BOOL)isNWOfRiver
{
    if ((self.river & FLOWDIRECTION_NORTHEAST_MASK) > 0)
        return YES;
    
    if ((self.river & FLOWDIRECTION_SOUTHWEST_MASK) > 0)
        return YES;
    
    return NO;
}

- (BOOL)isNEOfRiver
{
    if ((self.river & FLOWDIRECTION_NORTHWEST_MASK) > 0)
        return YES;
    
    if ((self.river & FLOWDIRECTION_SOUTHEAST_MASK) > 0)
        return YES;
    
    return NO;
}

- (BOOL)isRiverWithFlowDirection:(FlowDirection)flow
{
    switch (flow) {
        case FlowDirectionNorth:
            return ((self.river & FLOWDIRECTION_NORTH_MASK) > 0);
        case FlowDirectionNorthEast:
            return ((self.river & FLOWDIRECTION_NORTHEAST_MASK) > 0);
        case FlowDirectionSouthEast:
            return ((self.river & FLOWDIRECTION_SOUTHEAST_MASK) > 0);
        case FlowDirectionSouth:
            return ((self.river & FLOWDIRECTION_SOUTH_MASK) > 0);
        case FlowDirectionSouthWest:
            return ((self.river & FLOWDIRECTION_SOUTHWEST_MASK) > 0);
        case FlowDirectionNorthWest:
            return ((self.river & FLOWDIRECTION_NORTHWEST_MASK) > 0);
    }
    //return [self getRiverEFlowDirection] == flow || [self getRiverSEFlowDirection] == flow || [self getRiverSWFlowDirection] == flow;
}

- (FlowDirection)getRiverEFlowDirection
{
    if ((self.river & FLOWDIRECTION_NORTH_MASK) > 0)
        return FlowDirectionNorth;
    
    if ((self.river & FLOWDIRECTION_SOUTH_MASK) > 0)
        return FlowDirectionSouth;
    
    return NO_FLOWDIRECTION;
}

- (FlowDirection)getRiverSEFlowDirection
{
    if ((self.river & FLOWDIRECTION_NORTHEAST_MASK) > 0)
        return FlowDirectionNorthEast;
    
    if ((self.river & FLOWDIRECTION_SOUTHWEST_MASK) > 0)
        return FlowDirectionSouthWest;
    
    return NO_FLOWDIRECTION;
}

- (FlowDirection)getRiverSWFlowDirection
{
    if ((self.river & FLOWDIRECTION_NORTHWEST_MASK) > 0)
        return FlowDirectionNorthWest;
    
    if ((self.river & FLOWDIRECTION_SOUTHEAST_MASK) > 0)
        return FlowDirectionSouthEast;
    
    return NO_FLOWDIRECTION;
}

- (void)setWOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow
{
    if (flow != FlowDirectionNorth && flow != FlowDirectionSouth) {
        NSException *e = [NSException
                          exceptionWithName:@"WrongDirectionException"
                          reason:[NSString stringWithFormat:@"West of the plot can only flow the river from north to south and vice versa, not %d", flow]
                          userInfo:nil];
        @throw e;
    }
    
    int riverMask = (63 - (int) flow);
    self.river = (char) (self.river & riverMask);
    self.river += hasRiver ? (char)(1 << flow) : (char)0;
}

- (void)setNWOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow
{
    if (flow != FlowDirectionNorthEast && flow != FlowDirectionSouthWest) {
        NSException *e = [NSException exceptionWithName:@"WrongDirectionException"
                                                 reason:[NSString stringWithFormat:@"Northwest of the plot can only flow the river from northeast to southwest and vice versa, not %d", flow]
                                               userInfo:nil];
        @throw e;
    }
    
    int riverMask = (63 - (int)flow);
    self.river = (char)(self.river & riverMask);
    self.river += hasRiver ? (char)(1 << flow) : (char)0;
}

- (void)setNEOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow
{
    if (flow != FlowDirectionNorthWest && flow != FlowDirectionSouthEast) {
        NSException *e = [NSException exceptionWithName:@"WrongDirectionException"
                                                 reason:[NSString stringWithFormat:@"Northeast of the plot can only flow the river from northwest to southeast and vice versa, not %d", flow]
                                               userInfo:nil];
        @throw e;
    }
    
    int riverMask = (63 - (int)flow);
    self.river = (char)(self.river & riverMask);
    self.river += hasRiver ? (char)(1 << flow) : (char)0;
}

- (void)setRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow
{
    switch(flow)
    {
        case FlowDirectionSouth:
        case FlowDirectionNorth:
            [self setWOfRiver:hasRiver withFlowDirection:flow];
            break;
        case FlowDirectionSouthEast:
        case FlowDirectionNorthWest:
            [self setNEOfRiver:hasRiver withFlowDirection:flow];
            break;
        case FlowDirectionSouthWest:
        case FlowDirectionNorthEast:
            [self setNWOfRiver:hasRiver withFlowDirection:flow];
            break;
    }
}

- (BOOL)isRiverCrossingWithDirection:(HexDirection)direction
{
    return NO;
}

- (NSString *)atlasName
{
    NSString *atlasName = @"";
    
    if ([self isWOfRiver]) {
        atlasName = @"e,";
    }
    
    if ([self isNWOfRiver]) {
        atlasName = [NSString stringWithFormat:@"%@%@", atlasName, @"se,"];
    }
        
    if ([self isNEOfRiver]) {
        atlasName = [NSString stringWithFormat:@"%@%@", atlasName, @"sw,"];
    }
        
    return [atlasName trimWithCharacter:','];
}

@end
