//
//  HexagonMapItem.h
//  SimWorld
//
//  Created by Michael Rommel on 16.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HexRiver.h"

#define TERRAIN_OCEAN   @"TERRAIN_OCEAN"
#define TERRAIN_COAST   @"TERRAIN_COAST"
#define TERRAIN_GRASS   @"TERRAIN_GRASS"
#define TERRAIN_PLAINS  @"TERRAIN_PLAINS"
#define TERRAIN_DESERT  @"TERRAIN_DESERT"
#define TERRAIN_SNOW    @"TERRAIN_SNOW"
#define TERRAIN_TUNDRA  @"TERRAIN_TUNDRA"

#define FEATURE_HILL @"FEATURE_HILL"
#define FEATURE_MOUNTAIN @"FEATURE_MOUNTAIN"
#define FEATURE_FOREST @"FEATURE_FOREST"

@interface HexagonMapItem : NSObject

@property (nonatomic, retain) HexPoint *location;
@property (nonatomic, retain) NSString *terrain;
@property (nonatomic, retain) NSMutableArray *features;
@property (nonatomic, retain) HexRiver *river;

- (id)initWithLocationX:(int)x andLocationY:(int)y;

// features
- (BOOL)isForest;
- (BOOL)isHill;
- (BOOL)isMountain;

- (BOOL)isOcean;

@end
