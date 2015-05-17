//
//  SetupGameStepContent.h
//  SimWorld
//
//  Created by Michael Rommel on 18.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define kRainfallDefault    @"MAP_OPTION_NORMAL"
#define kTemperatureDefault @"MAP_OPTION_TEMPERATE"
#define kAgeDefault         @"MAP_OPTION_FOUR_BILLION_YEARS"
#define kResourcesDefault   @"MAP_OPTION_STANDARD"
#define kSeaLevelDefault    @"MAP_OPTION_MEDIUM"

@interface SetupGameStepContent : NSObject

@property (nonatomic,retain) NSString *leader;
@property (nonatomic,retain) NSString *mapType;
@property (nonatomic,retain) NSString *mapSize;
@property (nonatomic,retain) NSString *difficulty;

// values with default content
@property (nonatomic,retain) NSString *age;
@property (nonatomic,retain) NSString *rainfall;
@property (nonatomic,retain) NSString *temperature;
@property (nonatomic,retain) NSString *resources;
@property (nonatomic,retain) NSString *sealevel;

+ (SetupGameStepContent *)sharedInstance;

- (id)initWithDefaults;

- (CGSize)size;

- (NSString *)description;

@end