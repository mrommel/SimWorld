//
//  SetupGameStepContent.m
//  SimWorld
//
//  Created by Michael Rommel on 18.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "SetupGameStepContent.h"

@implementation SetupGameStepContent

static SetupGameStepContent *shared = nil;

+ (SetupGameStepContent *)sharedInstance
{
    @synchronized (self) {
        if (shared == nil) {
            shared = [[self alloc] initWithDefaults];
        }
    }
    
    return shared;
}

- (id)initWithDefaults
{
    self = [super init];
    
    if (self) {
        self.rainfall = kRainfallDefault;
        self.temperature = kTemperatureDefault;
        self.age = kAgeDefault;
        self.sealevel = kSeaLevelDefault;
        self.resources = kResourcesDefault;
    }
    
    return self;
}

/*
 Duel:      40 x 25  (2 players, 4 city-states, 2 natural wonders)
 Tiny:      56 x 36  (4 players, 8 city-states, 3 natural wonders)
 Small:     66 x 42  (6 players, 12 city-states, 3 natural wonders)
 Standard:  80 x 52  (8 players, 16 city-states, 4 natural wonders)
 Large:    104 x 64  (10 players, 20 city-states, 6 natural wonders)
 Huge:     128 x 80  (12 players, 24 city-states, 7 natural wonders)
 */
- (CGSize)size
{
    if ([self.mapSize isEqualToString:@"MAP_SIZE_DUEL"]) {
        return CGSizeMake(40, 25);
    } else if ([self.mapSize isEqualToString:@"MAP_SIZE_TINY"]) {
        return CGSizeMake(56, 36);
    } else if ([self.mapSize isEqualToString:@"MAP_SIZE_SMALL"]) {
        return CGSizeMake(66, 42);
    } else if ([self.mapSize isEqualToString:@"MAP_SIZE_STANDARD"]) {
        return CGSizeMake(80, 52);
    } else if ([self.mapSize isEqualToString:@"MAP_SIZE_LARGE"]) {
        return CGSizeMake(104, 64);
    } else if ([self.mapSize isEqualToString:@"MAP_SIZE_HUGE"]) {
        return CGSizeMake(128, 80);
    } else {
        NSLog(@"WARN: '%@' not a valid map size", self.mapSize);
        return CGSizeMake(40, 25);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SetupGameStepContent [leader:%@, type:%@, size:%@, handicap:%@ -- resources:%@, rain: %@, temp: %@, age: %@, sealevel: %@]", self.leader, self.mapType, self.mapSize, self.difficulty, self.resources, self.rainfall, self.temperature, self.age, self.sealevel];
}

@end