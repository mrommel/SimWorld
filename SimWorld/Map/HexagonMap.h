//
//  HexagonMap.h
//  SimWorld
//
//  Created by Michael Rommel on 17.11.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "Array2D.h"
@class HexPoint;

@interface HexagonMap : NSObject<NSStreamDelegate>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *text;
@property (atomic, assign) CGSize size;
@property (nonatomic, retain) Array2D *tiles;

//- (id)initWithFileName:(NSString *)fileName;
- (id)initWithCiv5Map:(NSString *)fileName;
- (id)initWithName:(NSString *)name andWidth:(int)width andHeight:(int)height;

- (BOOL)isValidAt:(HexPoint *)h;
- (BOOL)isValidAtX:(int)x andY:(int)y;

// terrain
- (NSString *)terrainAtX:(int)x andY:(int)y;
- (void)setTerrain:(NSString *)terrainName atX:(int)x andY:(int)y;
- (BOOL)isOceanAtX:(int)x andY:(int)y;

// features
- (void)addFeature:(NSString *)featureName atX:(int)x andY:(int)y;
- (BOOL)hasFeature:(NSString *)featureName atX:(int)x andY:(int)y;

// river functions
- (void)setRiver:(BOOL)hasRiver inFlowDirection:(int)flowDirection atX:(int)x andY:(int)y;
- (BOOL)hasRiverInFlowDirection:(int)flowDirection atX:(int)x andY:(int)y;
- (BOOL)hasRiverInDirection:(int)direction atX:(int)x andY:(int)y;

- (UIImage *)thumbnail;

@end
