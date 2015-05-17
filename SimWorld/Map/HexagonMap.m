//
//  HexagonMap.m
//  SimWorld
//
//  Created by Michael Rommel on 17.11.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexagonMap.h"

#import "XMLReader.h"
#import "NSDictionary+Extensions.h"
#import "HexagonMapItem.h"
#import "ByteReader.h"
#import "HexRiver.h"

#import "MathHelper.h"

#define RESOURCE_NO_RESOURCE    '\xff'

#define FEATURE_NO_FEATURE      '\xff'
#define FEATURE_HILL_ID         1
#define FEATURE_MOUNTAIN_ID         2

static NSString *const kPathMapWidth = @"Map/Size/Width";
static NSString *const kPathMapHeight = @"Map/Size/Height";

@interface HexagonMap() {
    
}

@end

@implementation HexagonMap

/*- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        NSString *xmlPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
        NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
        NSError *error = nil;
        NSDictionary *earthDict = [XMLReader dictionaryForXMLData:xmlData error:&error];
        
        if (error) {
            return nil;
        }
        
        long width = [earthDict getIntValueForKeyPath:kPathMapWidth withDefaultValue:0];
        long height = [earthDict getIntValueForKeyPath:kPathMapHeight withDefaultValue:0];
        self.size = CGSizeMake(width, height);
        
        self.tiles = [[Array2D alloc] initWithSize:self.size];
        NSArray* tiles = [earthDict getArrayForKeyPath:@"Map/Tiles/Item"];
        NSAssert([tiles count] == (width * height), @"number of tiles: %lu must match width * height= %ld", (unsigned long)[tiles count], (width * height));
        
        for (NSDictionary *tileDict in tiles) {
            int x = [tileDict getIntValueForKeyPath:@"X" withDefaultValue:0];
            int y = [tileDict getIntValueForKeyPath:@"Y" withDefaultValue:0];
            NSString *terrain = [tileDict getValueForKeyPath:@"Terrain"];
            NSString *river = [tileDict getValueForKeyPath:@"River"];
            NSArray *features = [tileDict getArrayForKeyPath:@"Features/Item"];
            
            //HexagonMapItem *item = [[HexagonMapItem alloc] initWithTerrain:terrain andFeatures:features andRiver:river];
            HexagonMapItem *item = [[HexagonMapItem alloc] initWithTerrain:terrain andFeatures:features andRiver:nil];
            [self.tiles setObject:item atX:x andY:y];
        }
    }
    
    return self;
}*/

- (id)initWithCiv5Map:(NSString *)fileName
{
    self = [super init];
    
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"Civ5Map"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        //NSLog(@"Data: %@", data);
        ByteReader *reader = [[ByteReader alloc] initWithData:data];

        char firstByte = [reader readByte];
        char version = firstByte & 0x0f;
        BOOL isScenario = firstByte & 0x80;
        int width = [reader readInt];
        int height = [reader readInt];
        
        NSLog(@"*** Loading Civ5Map version %d with %dx%d, scenario: %d", version, width, height, isScenario);
        
        /*char scenario = */[reader readByte]; // Players scenario
        /*int bitMask = */[reader readInt]; // Settings bitmask
        
        int lengthOfTerrains = [reader readInt]; // Length of terrains types
        int lengthOfFirstFeatures = [reader readInt]; // Length of first features types
        int lengthOfSecondFeatures = [reader readInt]; // Length of second features types
        int lengthOfResources = [reader readInt]; // Length of resource types
        int lengthOfMapName = [reader readInt]; // Length of map name
        int lengthOfDescription = [reader readInt]; // Length of description
        /*int unknown1 = */[reader readInt]; // skip
        
        NSArray *terrainList = [reader readStringArrayFromLength:lengthOfTerrains]; // Terrain type list
        NSArray *featuresFirstList = [reader readStringArrayFromLength:lengthOfFirstFeatures]; // 1st Feature type list
        NSArray *featuresSecondList = [reader readStringArrayFromLength:lengthOfSecondFeatures]; // 2nd Feature type list
        NSArray *resourceList = [reader readStringArrayFromLength:lengthOfResources]; // resource type list
        
        self.name = [reader readString]; // [reader readStringWithLength:lengthOfMapName];
        self.text = [reader readString]; // [reader readStringWithLength:lengthOfDescription];
        if (lengthOfMapName == 0) {
            self.name = @"";
        }
        if (lengthOfDescription == 0) {
            self.text = @"";
        }
        //NSLog(@"Map: '%@' = %d - '%@' = %d", self.name, lengthOfMapName, self.text, lengthOfDescription);
        
        self.size = CGSizeMake(width, height);
        self.tiles = [[Array2D alloc] initWithSize:self.size];
        
        if (version >= 0x0b) {
            int unknown2 = [reader readInt];
            // read 64 bytes
            for (int i = 0; i < 16; i++) {
                [reader readInt]; // 4 bytes
            }
        }
        
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                [self.tiles setObject:[[HexagonMapItem alloc] initWithLocationX:x andLocationY:y] atX:x andY:y];
            }
        }
        
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                // terrain
                char terrainVal = [reader readByte]; // 0
                NSString *terrainStr = [terrainList objectAtIndex:terrainVal];
                
                // resource
                char resourceVal = [reader readByte]; // 1
                NSString *resourceStr = @"";
                if (resourceVal != RESOURCE_NO_RESOURCE) {
                    resourceStr = [resourceList objectAtIndex:resourceVal];
                }
                    
                // 1st features
                NSMutableArray *features = [[NSMutableArray alloc] init];
                char firstFeatureVal = [reader readByte]; // 2
                if (firstFeatureVal != FEATURE_NO_FEATURE) {
                    [features addObject:[featuresFirstList objectAtIndex:firstFeatureVal]];
                }
                
                // rivers
                char riverVal = [reader readByte]; // 3
                
                // hills / mountains
                char elevationVal = [reader readByte]; // 4, 1 = hills, 2 = mountains
                if (elevationVal == FEATURE_HILL_ID) {
                    [features addObject:FEATURE_HILL];
                } else if (elevationVal == FEATURE_MOUNTAIN_ID) {
                    [features addObject:FEATURE_MOUNTAIN];
                } else if (elevationVal != 0){
                    NSLog(@"Unexpected ");
                }
                
                /*char continentVal = */[reader readByte]; // 5
                char secondFeatureVal = [reader readByte]; // 6
                if (secondFeatureVal != FEATURE_NO_FEATURE) {
                    [features addObject:[featuresSecondList objectAtIndex:secondFeatureVal]];
                }
                
                /*char unknownVal = */[reader readByte]; // 7
                
                // apply values
                HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
                
                [self plot:item setTerrain:terrainStr];
                [self plot:item setFeatures:features];
                
                if (riverVal & FLOWDIRECTION_NORTH_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_NORTH];
                }
                if (riverVal & FLOWDIRECTION_SOUTH_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_SOUTH];
                }
                if (riverVal & FLOWDIRECTION_NORTHEAST_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_NORTHEAST];
                }
                if (riverVal & FLOWDIRECTION_SOUTHWEST_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_SOUTHWEST];
                }
                if (riverVal & FLOWDIRECTION_SOUTHEAST_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_SOUTHEAST];
                }
                if (riverVal & FLOWDIRECTION_NORTHWEST_MASK) {
                    [self plot:item setRiver:YES inFlowDirection:FLOWDIRECTION_NORTHWEST];
                }
            }
        }
        
        NSString *gameSpeed = [reader readString];
        NSString *tmp = [reader readStringWithLength:200];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name andWidth:(int)width andHeight:(int)height
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.text = @"";
    
        self.size = CGSizeMake(width, height);
        self.tiles = [[Array2D alloc] initWithSize:self.size];
    
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                [self.tiles setObject:[[HexagonMapItem alloc] initWithLocationX:x andLocationY:y] atX:x andY:y];
            }
        }
    }
    
    return self;
}

- (BOOL)isValidAt:(HexPoint *)h
{
    if (h == nil) {
        return NO;
    }
    
    return ((h.x >= 0) && (h.y >= 0) && (h.x < (int)self.tiles.size.width) && (h.y < (int)self.tiles.size.height));
}

- (BOOL)isValidAtX:(int)x andY:(int)y
{
    return ((x >= 0) && (y >= 0) && (x < (int)self.tiles.size.width) && (y < (int)self.tiles.size.height));
}

#pragma mark -
#pragma mark terrain functions

- (NSString *)terrainAtX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    return item.terrain;
}

- (void)setTerrain:(NSString *)terrainName atX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    [self plot:item setTerrain:terrainName];
}

- (BOOL)isOceanAtX:(int)x andY:(int)y
{
    if (![self isValidAtX:x andY:y]) {
        return NO;
    }
    
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    return [item isOcean];
}

#pragma mark -
#pragma mark feature functions

- (void)addFeature:(NSString *)featureName atX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    [self plot:item addFeature:featureName];
}

- (BOOL)hasFeature:(NSString *)featureName atX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    return [self plot:item hasFeature:featureName];
}

- (void)setRiver:(BOOL)hasRiver inFlowDirection:(int)flowDirection atX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    [self plot:item setRiver:hasRiver inFlowDirection:flowDirection];
}

- (BOOL)hasRiverInFlowDirection:(int)flowDirection atX:(int)x andY:(int)y
{
    if (![self isValidAtX:x andY:y]) {
        return NO;
    }
    
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    return [self plot:item hasRiverInFlowDirection:flowDirection];
}

- (BOOL)hasRiverInDirection:(int)direction atX:(int)x andY:(int)y
{
    HexagonMapItem *item = [self.tiles objectAtX:x andY:y];
    return [self plot:item hasRiverInDirection:direction];
    //return (int)[self plot:item riverFlowInDirection:direction] != NO_FLOWDIRECTION;
}

- (UIImage *)thumbnail
{
    UIColor *green = [UIColor greenColor];
    UIColor *blue = [UIColor blueColor];
    UIColor *black = [UIColor blackColor];
    
    CGSize newSize = CGSizeMake(256, 256);
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [black CGColor]);
    CGContextFillRect(context, CGRectMake(0,0,255,255));
    
    float factor = MAX(self.size.width, self.size.height) / 256.0f;
    float dx = (256.0f - self.size.width / factor) / 2.0f;
    float dy = (256.0f - self.size.height / factor) / 2.0f;
    
    for (int y = 0; y < 256; ++y) {
        for (int x = 0; x < 256; ++x) {
            
            int mx = ((float)x) * factor;
            int my = ((float)y) * factor;
            
            if (mx < self.size.width && my < self.size.height) {
                HexagonMapItem *item = [self.tiles objectAtX:mx andY:my];
                if ([item isOcean]) {
                    CGContextSetFillColorWithColor(context, [blue CGColor]);
                } else {
                    CGContextSetFillColorWithColor(context, [green CGColor]);
                }
            } else {
                CGContextSetFillColorWithColor(context, [black CGColor]);
            }
            CGContextFillRect(context, CGRectMake(dx + x,256 - (dy + y),1,1));
        }
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return finalImage;
}

- (BOOL)plot:(HexagonMapItem *)plot setTerrain:(NSString *)terrain
{
    plot.terrain = terrain;
    return YES;
}

- (BOOL)plot:(HexagonMapItem *)plot setFeatures:(NSArray *)features
{
    plot.features = [features mutableCopy];
    return YES;
}

- (BOOL)plot:(HexagonMapItem *)plot addFeature:(NSString *)feature
{
    [plot.features addObject:feature];
    return YES;
}

- (BOOL)plot:(HexagonMapItem *)plot hasFeature:(NSString *)feature
{
    for (id obj in plot.features) {
        if ([obj isEqualToString:feature]) {
            return YES;
        }
    }
    
    return NO;
}

- (HexagonMapItem *)plot:(HexagonMapItem *)plot inDirection:(HexDirection)direction
{
    HexPoint *tmp = [plot.location neighborIn:direction];
    return [self.tiles objectAtX:tmp.x andY:tmp.y];
}
            
- (BOOL)plot:(HexagonMapItem *)plot hasRiverInFlowDirection:(int)flowDirection
{
    return [plot.river isRiverWithFlowDirection:flowDirection];
}

- (BOOL)plot:(HexagonMapItem *)plot hasRiverInDirection:(HexDirection)direction
{
    if (direction == HexDirectionEast) {
        return [plot.river isWOfRiver];
    }
    
    if (direction == HexDirectionSouthEast) {
        return [plot.river isNWOfRiver];
    }
    
    if (direction == HexDirectionSouthWest) {
        return [plot.river isNEOfRiver];
    }
    
    HexagonMapItem *neighbor = [self plot:plot inDirection:direction];
    return [self plot:neighbor hasRiverInDirection:OPPOSITE_DIRECTION(direction)];
}

- (FlowDirection)plot:(HexagonMapItem *)plot riverFlowInDirection:(HexDirection)direction
{
    if (direction == HexDirectionEast) {
        return [plot.river getRiverEFlowDirection];
    }

    if (direction == HexDirectionSouthEast) {
        return [plot.river getRiverSEFlowDirection];
    }
    
    if (direction == HexDirectionSouthWest) {
        return [plot.river getRiverSWFlowDirection];
    }
    
    HexagonMapItem *neighbor = [self plot:plot inDirection:direction];
    return [self plot:neighbor riverFlowInDirection:OPPOSITE_DIRECTION(direction)];
}

- (BOOL)plot:(HexagonMapItem *)plot
    setRiver:(BOOL)hasRiver
inFlowDirection:(FlowDirection)flowDirection
{
    if (flowDirection == FLOWDIRECTION_NORTH || flowDirection == FLOWDIRECTION_SOUTH) {
        [self plot:plot setRiver:hasRiver inDirection:HexDirectionEast andFlowDirection:flowDirection];
        return YES;
    }
    
    if (flowDirection == FLOWDIRECTION_NORTHEAST || flowDirection == FLOWDIRECTION_SOUTHWEST) {
        [self plot:plot setRiver:hasRiver inDirection:HexDirectionSouthEast andFlowDirection:flowDirection];
        return YES;
    }
    
    if (flowDirection == FLOWDIRECTION_NORTHWEST || flowDirection == FLOWDIRECTION_SOUTHEAST) {
        [self plot:plot setRiver:hasRiver inDirection:HexDirectionSouthWest andFlowDirection:flowDirection];
        return YES;
    }
    
    return NO;
}

- (BOOL)plot:(HexagonMapItem *)plot
    setRiver:(BOOL)hasRiver
 inDirection:(HexDirection)direction
andFlowDirection:(FlowDirection)flowDirection
{
    if (direction == HexDirectionEast) {
        [plot.river setWOfRiver:hasRiver withFlowDirection:flowDirection];
        return YES;
    }
    
    if (direction == HexDirectionSouthEast) {
        [plot.river setNWOfRiver:hasRiver withFlowDirection:flowDirection];
        return YES;
    }
    
    if (direction == HexDirectionSouthWest) {
        [plot.river setNEOfRiver:hasRiver withFlowDirection:flowDirection];
        return YES;
    }
    
    HexagonMapItem *neighbor = [self plot:plot inDirection:direction];
    return [self plot:neighbor setRiver:hasRiver inDirection:OPPOSITE_DIRECTION(direction) andFlowDirection:flowDirection];
}

#pragma mark -
#pragma mark translation functions

- (GLKVector3)worldPositionFromX:(int)tilex andY:(int)tiley
{
    float rx, ry;
    [HexPoint hexWithX:tilex andY:tiley toX:&rx andY:&ry];
    
    return GLKVector3Make(rx, 0, ry);
}

- (GLKVector3)worldPositionFromHex:(HexPoint *)pt
{
    float rx, ry;
    [HexPoint hexWithX:pt.x andY:pt.y toX:&rx andY:&ry];
    
    return GLKVector3Make(rx, 0, ry);
}

- (HexPoint *)mapPositionFromWorldPosition:(GLKVector3)position
{
    int hx, hy;
    [HexPoint worldWithX:(int)position.x andY:(int)position.z toX:&hx andY:&hy];
    return [[HexPoint alloc] initWithX:hx andY:hy];
}

@end
