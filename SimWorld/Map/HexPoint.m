//
//  HexPoint.m
//  SimWorld
//
//  Created by Michael Rommel on 19.11.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexPoint.h"

#define EVEN(x)     ((x % 2) == 0)
#define ODD(x)     ((x % 2) == 1)

#define kHexPointSettingWidth 1.0f // 1
#define kHexPointSettingHeight 0.8f // 0.7f
#define kHexPointSettingToogleOffset 0.5f
#define kHexPointSettingOffset 0.2f

@implementation HexPoint

//      1
//   /  |  \
//  6 \ | / 2
//  |   0   |
//  5 / | \ 3
//   \  |  /
//      4

- (id)initWithX:(int)x andY:(int)y
{
    self = [super init];
    
    if (self) {
        self.x = x;
        self.y = y;
    }
    
    return self;
}

- (HexPoint *)neighborIn:(HexDirection)direction
{
    switch (direction) {
        case HexDirectionNorthEast:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x andY:self.y-1];
            } else {
                return [[HexPoint alloc] initWithX:self.x+1 andY:self.y-1];
            }
            break;
        case HexDirectionEast:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x+1 andY:self.y];
            } else {
                return [[HexPoint alloc] initWithX:self.x+1 andY:self.y];
            }
            break;
        case HexDirectionSouthEast:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x andY:self.y+1];
            } else {
                return [[HexPoint alloc] initWithX:self.x+1 andY:self.y+1];
            }
            break;
        case HexDirectionSouthWest:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x-1 andY:self.y+1];
            } else {
                return [[HexPoint alloc] initWithX:self.x andY:self.y+1];
            }
            break;
        case HexDirectionWest:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x-1 andY:self.y];
            } else {
                return [[HexPoint alloc] initWithX:self.x-1 andY:self.y];
            }
            break;
        case HexDirectionNorthWest:
            if (EVEN(self.x)) {
                return [[HexPoint alloc] initWithX:self.x-1 andY:self.y-1];
            } else {
                return [[HexPoint alloc] initWithX:self.x andY:self.y-1];
            }
            break;
    }
    
    return nil;
}

- (float)angleInRadianTo:(HexPoint *)other
{
    return 0.0f;
}

- (float)angleInDegreeTo:(HexPoint *)other
{
    return 0.0f;
}

+ (void)hexWithX:(int)hx andY:(int)hy toX:(float *)rx andY:(float *)ry
{
    (*rx) = hx * kHexPointSettingWidth + ((hy % 2 == 1 ? 1 : 0) * kHexPointSettingToogleOffset);
    (*ry) = hy * kHexPointSettingHeight - kHexPointSettingOffset;
}

+ (void)worldWithX:(float)rx andY:(float)ry toX:(int *)hx andY:(int *)hy
{
    //  FI  FII
    //+---+---+
    //|  / \  |
    //|/     \|
    //+       +
    //|       |
    //+       +
    //|\     /|
    //|  \ /  |
    //+---+---+
    
    int deltaWidth = kHexPointSettingWidth / 2;
    int ergx;
    bool moved;
    
    ry -= 10;
    
    //GrobRasterung
    int ergy = ry / kHexPointSettingHeight;
    if (ergy % 2 == 1)
    {
        moved = false;
        ergx = rx / kHexPointSettingWidth;
    }
    else
    {
        moved = true;
        ergx = (rx - deltaWidth) / kHexPointSettingWidth;
    }
    
    //FehlerKorrektur
    int crossPoint; //X
    if (moved)
        crossPoint = ergx * kHexPointSettingWidth + deltaWidth;
    else
        crossPoint = ergx * kHexPointSettingWidth;
    
    //Fehler I
    double tmp = -(22.0 / 8.0) * (ry - ergy * kHexPointSettingHeight) + crossPoint;
    
    if (((rx - deltaWidth) < tmp) && (moved))
    {
        ergy--;
    }
    if (((rx - deltaWidth) < tmp) && (!moved))
    {
        ergx--;
        ergy--;
    }
    
    // Fehler II
    tmp = (22.0 / 8.0) * (ry - ergy * kHexPointSettingHeight) + crossPoint;
    if (((rx - deltaWidth) > tmp) && (moved))
    {
        ergy--;
        ergx++;
    }
    if (((rx - deltaWidth) > tmp) && (!moved))
    {
        ergy--;
    }
    
    // Realisierung
    if (hx && hy) {
        (*hx) = (ergx < 0) ? -1 : ergx;
        (*hy) = (ergy < 0) ? -1 : ergy;
    }
}

-(HexPointWithCorner *)hexPointWithCorner:(HexPointCorner)corner
{
    return [[HexPointWithCorner alloc] initWithX:self.x andY:self.y andCorner:corner];
}

@end

@implementation HexPointWithCorner

- (id)initWithX:(int)x andY:(int)y andCorner:(HexPointCorner)corner
{
    self = [super initWithX:x andY:y];
    
    if (self) {
        self.corner = corner;
    }
    
    return self;
}

- (id)initWithHex:(HexPoint *)hex andCorner:(HexPointCorner)corner
{
    self = [super initWithX:hex.x andY:hex.y];
    
    if (self) {
        self.corner = corner;
    }
    
    return self;
}

- (NSArray *)possibleFlowsFromCorner
{
    NSMutableArray *flows = [[NSMutableArray alloc] init];
    
    switch (self.corner) {
        case HexPointCornerNorth: // 6 -> 0, 2, 4
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthWest]];
            break;
        case HexPointCornerNorthEast:
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthWest]];
            break;
        case HexPointCornerSouthEast:
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthWest]];
            break;
        case HexPointCornerSouth:
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthWest]];
            break;
        case HexPointCornerSouthWest:
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouthWest]];
            break;
        case HexPointCornerNorthWest:
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthEast]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionSouth]];
            [flows addObject:[NSNumber numberWithInt:FlowDirectionNorthWest]];
            break;
    }
    
    return flows;
}

// this method has errors:
// - not all corners should exist since flows only have 3 positions
//   (so north and northwest corner should not be returned nor accepted)
//
//     n
//   /   ≠
// n       y
// |       |  north /
// |       |  south
// y       y
//   ≠   /  south west / north east
//  |  y
//  |
//  south east / north west
//
- (HexPointWithCorner *)nextCornerInFlowDirection:(FlowDirection)flowDirection
{    
    HexPoint *neighbor;
    switch (self.corner) {
        case HexPointCornerNorth:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Not a valid corner: %@ for flow calculation.", CornerString(self.corner)];
            break;
        case HexPointCornerNorthEast:
            switch (flowDirection) {
                case FlowDirectionNorth:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionNorthEast:
                    neighbor = [self neighborIn:HexDirectionNorthEast];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouthEast];
                    break;
                case FlowDirectionSouthEast:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouth:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerSouthEast];
                    break;
                case FlowDirectionSouthWest:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionNorthWest:
                    neighbor = [self neighborIn:HexDirectionNorthWest];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouthEast];
                    break;
            }
            break;
        case HexPointCornerSouthEast:
            switch (flowDirection) {
                case FlowDirectionNorth:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerNorthEast];
                    break;
                case FlowDirectionNorthEast:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouthEast:
                    neighbor = [self neighborIn:HexDirectionEast];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouth];
                    break;
                case FlowDirectionSouth:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouthWest:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerSouth];
                    break;
                case FlowDirectionNorthWest:
                    // NOOP - will raise exception
                    break;
            }
            break;
        case HexPointCornerSouth:
            switch (flowDirection) {
                case FlowDirectionNorth:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionNorthEast:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerSouthEast];
                    break;
                case FlowDirectionSouthEast:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouth:
                    neighbor = [self neighborIn:HexDirectionSouthEast];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouthWest];
                    break;
                case FlowDirectionSouthWest:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionNorthWest:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerSouthWest];
                    break;
            }
            break;
        case HexPointCornerSouthWest:
            switch (flowDirection) {
                case FlowDirectionNorth:
                    neighbor = [self neighborIn:HexDirectionNorthWest];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouth];
                    break;
                case FlowDirectionNorthEast:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouthEast:
                    return [[HexPointWithCorner alloc] initWithHex:self andCorner:HexPointCornerSouth];
                    break;
                case FlowDirectionSouth:
                    // NOOP - will raise exception
                    break;
                case FlowDirectionSouthWest:
                    neighbor = [self neighborIn:HexDirectionWest];
                    return [[HexPointWithCorner alloc] initWithHex:neighbor andCorner:HexPointCornerSouthWest];
                    break;
                case FlowDirectionNorthWest:
                    // NOOP - will raise exception
                    break;
            }
            break;
        case HexPointCornerNorthWest:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Not a valid corner: %@ for flow calculation.", CornerString(self.corner)];
            break;
    }
    
    [NSException raise:NSInternalInconsistencyException
                format:@"Cannot find next corner for (%d,%d) at corner %@ in direction %@", self.x, self.y, CornerString(self.corner), FlowDirectionString(flowDirection)];
    return nil;
}

@end
