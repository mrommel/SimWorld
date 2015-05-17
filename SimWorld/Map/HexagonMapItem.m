//
//  HexagonMapItem.m
//  SimWorld
//
//  Created by Michael Rommel on 16.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexagonMapItem.h"

@implementation HexagonMapItem

- (id)initWithLocationX:(int)x andLocationY:(int)y;
{
    self = [super init];
    
    if (self) {
        self.location = [[HexPoint alloc] initWithX:x andY:y];
        self.terrain = TERRAIN_OCEAN;
        self.features = [[NSMutableArray alloc] init];
        self.river = [[HexRiver alloc] initWithNumber:0];
    }
    
    return self;
}

- (BOOL)isOcean
{
    if ([self.terrain isEqualToString:TERRAIN_OCEAN] || [self.terrain isEqualToString:TERRAIN_COAST]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isForest
{
    for (NSString *feature in self.features) {
        if ([feature isEqualToString:FEATURE_FOREST]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isHill
{
    for (NSString *feature in self.features) {
        if ([feature isEqualToString:FEATURE_HILL]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isMountain
{
    for (NSString *feature in self.features) {
        if ([feature isEqualToString:FEATURE_MOUNTAIN]) {
            return YES;
        }
    }
    
    return NO;
}

@end
