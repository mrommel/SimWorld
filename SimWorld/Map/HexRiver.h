//
//  HexRiver.h
//  SimWorld
//
//  Created by Michael Rommel on 01.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HexPoint.h"

@interface HexRiver : NSObject

- (id)initWithNumber:(int)riverVal;

- (BOOL)isWOfRiver;
- (BOOL)isNWOfRiver;
- (BOOL)isNEOfRiver;

- (BOOL)isRiverWithFlowDirection:(FlowDirection)flow;

- (FlowDirection)getRiverEFlowDirection;
- (FlowDirection)getRiverSEFlowDirection;
- (FlowDirection)getRiverSWFlowDirection;

- (void)setWOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow;
- (void)setNWOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow;
- (void)setNEOfRiver:(BOOL)hasRiver withFlowDirection:(FlowDirection)flow;

- (BOOL)isRiverCrossingWithDirection:(HexDirection)direction;

- (NSString *)atlasName;

@end
