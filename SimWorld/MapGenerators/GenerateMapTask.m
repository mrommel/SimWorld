//
//  GenerateMapTask.m
//  SimWorld
//
//  Created by Michael Rommel on 06.01.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "GenerateMapTask.h"

#import "SetupGameStepContent.h"
#import "HexPoint.h"
#import "HexagonMapItem.h"
#import "CC3Math.h"

// Heightspartions
#define kDeepSea        2*16- 0
#define kNormalSea      4*16-10
#define kWaterDepth     6*16-32
#define kFlatLand       9*16-48
#define kHills          10*16-50
#define kLowMountain    11*16-50
#define kMidMountain    12*16-50
#define kHighMountain   13*16-50

#define pDeepSea        0
#define pNormalSea      1
#define pFlatSea        2
#define pIsland         3
#define pIceberg        4
#define pGlacier        5
#define pWasteland      6
#define pTaiga          7

#define pTundra         8
#define pConiferous     9
#define pMeadow1        10
#define pMixedforest    11
#define pMeadow2        12
#define pDeciduous      13
#define pMeadow3        14
#define pBushes         15

#define pMeadow4        16
#define pSavanne        17
#define pSteppe         18
#define pMoor           19
#define pSwamp1         20
#define pRainforest     21
#define pSwamp2         22
#define pJungle         23

#define pMeadow5        24
#define pWildDesert     25
#define pDesert         26
#define pLake           27
#define pHill           28
#define pLowMountain    29
#define pMidMountain    30
#define pHighMountain   31

#define pSpPlain        32
#define pSpHill         33

//Part of Scape in % of Northsphere
#define latitudePolar       5
#define latitudeSubPolar	25
#define latitudeGemaessigt  50
#define latitudeSubTropic	75
#define latitudeTropic      100

// climate zones
typedef enum Climate {
    cPolar = 0,
    cSubPolar = 1,
    cGemaessigt = 2,
    cSubTropen = 3,
    cTropen = 4
} Climate;

@implementation GenerateMapTask

- (void)preExecute
{
    //Method to override
}

- (NSInteger)doInBackground:(NSDictionary *)parameters
{
    int numLakes = [[parameters objectForKey:kParamNumberOfLakes] intValue];
    int numRivers = [[parameters objectForKey:kParamNumberOfRivers] intValue];
    
    [self updateProgress:0];
    CGSize size = [[SetupGameStepContent sharedInstance] size];
    self.map = [[HexagonMap alloc] initWithName:@"Generated" andWidth:size.width andHeight:size.height];
    //int maxSize = 256;
    
    // Step 0.1 Bodenschätze initialisieren
    // TODO
    [self updateProgress:10];
    
    // Step 0.2 resize matrices
    // TODO
    [self updateProgress:15];
    
    //Step 1.1 Höhen(raster)gitter erzeugen
    self.heightMap = [[HeightMap alloc] initWithSize:CGSizeMake(size.width, size.height)];
    [self updateProgress:20];
    
    //Step 1.2 Vegetation erzeugen
    Array2D *vegetationMap = [[Array2D alloc] initWithSize:CGSizeMake(size.width, size.height)];
    [self updateProgress:30];
    
    //Step 1.3 Work erzeugen und initializieren
    self.tmpMap = [[Array2D alloc] initWithSize:CGSizeMake(size.width, size.height)];
    [self.tmpMap fillWithInt:0];
    [self updateProgress:30];
    
    //Step 2.1 fill heightmap with random (sinus/cosinus) values
    [self.heightMap random];
    [self updateProgress:35];
    
    // Step 2.2 blur heights
    [self.heightMap smoothen];
    [self updateProgress:45];
    
    //Step 2.3 Ozeane und Berg und Rest(=Sp...) generieren
    [self setOceansAndMountains];
    [self updateProgress:50];
    
    //Step 2.4 Ozeane glätten
    [self checkOcean];
    [self updateProgress:60];
    
    //Step 3.1 Vegetation glätten
    [vegetationMap smoothenInt];
    [self updateProgress:70];
    
    // Step 3.2 generate SpPlain and SpHill
    [self modifyWorkWithVegetation:vegetationMap];
    [self updateProgress:75];
    
    // Step 3.3 generate Islands from FlatSea
    [self generateIslands];
    [self updateProgress:80];
    
    // Step 4 transform tmp to map terrain
    [self transformWork];
    [self updateProgress:85];
    
    //Step 5.1 Flüsse
    /*
     for(int count=0;count<rNumOfRivers;)
     if (makeRiver(rand()%dimx,rand()%dimy,height)) count++;*/
    [self generateRivers:((numRivers == kNoRivers) ? kNumberOfRivers : numRivers)];
    [self updateProgress:90];
    
    //Step 5.2 lakes
    [self generateLakes:((numLakes == kNoLakes) ? kNumberOfLakes : numLakes)];
    [self updateProgress:95];
    
    [self findContinents];
    //[self countContinentSizes];
    //[self resetContinentNames];
    
    //set Startpositionen
    //HexList start = findStartPositions(16);
    [self updateProgress:100];
    
    return 1;
}

- (void)findContinents
{
    
}

- (void)generateRivers:(int)numberOfRivers
{
    for(int count=0;count<numberOfRivers;) {
        if ([self tryToMakeRiverAtX:rand()%(int)self.map.size.width andY:rand()%(int)self.map.size.height]) {
            count++;
        }
    }
}

- (BOOL)tryToMakeRiverAtX:(int)x andY:(int)y
{
    // no rivers in oceans
    if ([self isOceanAtX:x andY:y]) {
        return NO;
    }
    
    // rivers start at hill or mountains
    if (![self isHillOrMountainAtX:x andY:y]) {
        return NO;
    }
    
    NSLog(@"-------------------------------");
    NSLog(@"Start Making River");
    
    HexPointWithCorner *currentPointWithCorner = [[HexPointWithCorner alloc] initWithX:x andY:y andCorner:HexPointCornerSouthEast];
    FlowDirection currentFlow = FLOWDIRECTION_SOUTH;
    BOOL riverReachedOcean = NO;
    BOOL riverReachedLake = NO;
    int riverLength = 0;
    
    while (!riverReachedOcean && !riverReachedLake) {
        
        NSLog(@"Current Cursor position: (%d,%d) at corner: %@", currentPointWithCorner.x, currentPointWithCorner.y, CornerString(currentPointWithCorner.corner));
        NSLog(@"Make River at: (%d,%d) in Flow:%@", currentPointWithCorner.x, currentPointWithCorner.y, FlowDirectionString(currentFlow));
        [self.map setRiver:YES inFlowDirection:currentFlow atX:currentPointWithCorner.x andY:currentPointWithCorner.y];
        riverLength++;

        float bestHeight = HUGE_VALF;
        FlowDirection bestFlow = NO_FLOWDIRECTION;
        
        for (NSNumber *flow in [currentPointWithCorner possibleFlowsFromCorner]) {
            HexPointWithCorner *flowPointWithCorner = [currentPointWithCorner nextCornerInFlowDirection:[flow intValue]];
            float flowHeight = [self heightAtPointWithCorner:flowPointWithCorner];
            if (bestHeight > flowHeight) {
                bestFlow = [flow intValue];
                bestHeight = flowHeight;
            }
        }
        
        currentFlow = bestFlow;
        currentPointWithCorner = [currentPointWithCorner nextCornerInFlowDirection:bestFlow];
        
        // check if we reached the edge of the map
        if (![self.map isValidAtX:currentPointWithCorner.x andY:currentPointWithCorner.y]) {
            riverReachedOcean = YES;
        }
        
        // check if river cannot excape
        if ([self.map hasRiverInFlowDirection:OPPOSITE_FLOWDIRECTION(currentFlow) atX:currentPointWithCorner.x andY:currentPointWithCorner.y]) {
            riverReachedLake = YES;
            NSLog(@"River reached lake");
        }
        
        // check if tile is adjacent to ocean
        if ([self.map isOceanAtX:currentPointWithCorner.x andY:currentPointWithCorner.y]) {
            riverReachedOcean = YES;
            NSLog(@"River reached ocean");
        }
    }
    
    return YES;
}

- (float)heightAtPointWithCorner:(HexPointWithCorner *)hexPointWithCorner
{
    return [self heightAtCorner:hexPointWithCorner.corner ofX:hexPointWithCorner.x andY:hexPointWithCorner.y];
}

- (float)heightAtCorner:(HexPointCorner)corner ofX:(int)x andY:(int)y
{
    HexPoint *current = [[HexPoint alloc] initWithX:x andY:y];
    HexPoint *pt1 = nil;
    HexPoint *pt2 = nil;
    
    //       N
    //       x
    // NW  /   \  NE
    //   x       x
    //   |       |
    //   |       |
    //   x       x
    // SW  \   /  SE
    //       x
    //       S
    switch (corner) {
        case HexPointCornerNorth:
            pt1 = [current neighborIn:HexDirectionNorthWest];
            pt2 = [current neighborIn:HexDirectionNorthEast];
            break;
        case HexPointCornerNorthEast:
            pt1 = [current neighborIn:HexDirectionNorthEast];
            pt2 = [current neighborIn:HexDirectionEast];
            break;
        case HexPointCornerSouthEast:
            pt1 = [current neighborIn:HexDirectionEast];
            pt2 = [current neighborIn:HexDirectionSouthEast];
            break;
        case HexPointCornerSouth:
            pt1 = [current neighborIn:HexDirectionSouthEast];
            pt2 = [current neighborIn:HexDirectionSouthWest];
            break;
        case HexPointCornerSouthWest:
            pt1 = [current neighborIn:HexDirectionSouthWest];
            pt2 = [current neighborIn:HexDirectionWest];
            break;
        case HexPointCornerNorthWest:
            pt1 = [current neighborIn:HexDirectionWest];
            pt2 = [current neighborIn:HexDirectionNorthWest];
            break;
    }
    
    return [self averageHeightOfPoint1:current andPoint2:pt1 andPoint3:pt2];
}

- (float)averageHeightOfPoint1:(HexPoint *)pt1 andPoint2:(HexPoint *)pt2 andPoint3:(HexPoint *)pt3
{
    float sum = 0.0f;
    int count = 0;
    
    if ([self.map isValidAt:pt1]) {
        count++;
        sum += [self.heightMap valueAtX:pt1.x andY:pt1.y];
    }
    
    if ([self.map isValidAt:pt2]) {
        count++;
        sum += [self.heightMap valueAtX:pt2.x andY:pt2.y];
    }
    
    if ([self.map isValidAt:pt3]) {
        count++;
        sum += [self.heightMap valueAtX:pt3.x andY:pt3.y];
    }
    
    if (count == 0) {
        return 0.0f;
    }
    
    return sum / count;
}

- (void)generateLakes:(int)numberOfLakes
{
    /*
     for(count=0;count<rNumOfLakes;)
     {
     int nx = rand()%dimx; int ny = rand()%dimy;
     setPlain(nx,ny,generateLakes(getPlain(nx,ny),isRiver(nx,ny),count));
     }*/
}

- (void)transformWork
{
    for (int i = 0; i < self.map.size.width; i++) {
        for (int j = 0; j < self.map.size.height; j++) {
            int tmpValue = [self.tmpMap intAtX:i andY:j];
            
            switch (tmpValue) {
                case pDeepSea:
                    [self.map setTerrain:TERRAIN_OCEAN atX:i andY:j];
                    break;
                case pNormalSea:
                    [self.map setTerrain:TERRAIN_OCEAN atX:i andY:j];
                    break;
                case pFlatSea:
                    [self.map setTerrain:TERRAIN_OCEAN atX:i andY:j];
                    break;
                case pIsland:
                    [self.map setTerrain:TERRAIN_OCEAN atX:i andY:j];
                    break;
                case pIceberg:
                    [self.map setTerrain:TERRAIN_OCEAN atX:i andY:j];
                    break;
                case pGlacier:
                    [self.map setTerrain:TERRAIN_SNOW atX:i andY:j];
                    break;
                case pWasteland:
                    [self.map setTerrain:TERRAIN_TUNDRA atX:i andY:j];
                    break;
                case pTaiga: // 7
                    [self.map setTerrain:TERRAIN_TUNDRA atX:i andY:j];
                    [self.map addFeature:FEATURE_FOREST atX:i andY:j];
                    break;
                case pTundra:
                    [self.map setTerrain:TERRAIN_TUNDRA atX:i andY:j];
                    break;
                case pConiferous:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pMixedforest:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_FOREST atX:i andY:j];
                    break;
                case pMeadow2:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pDeciduous:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_FOREST atX:i andY:j];
                    break;
                case pMeadow3:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pBushes: // 15
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pMeadow4:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pSavanne:
                    [self.map setTerrain:TERRAIN_PLAINS atX:i andY:j];
                    break;
                case pSteppe:
                    [self.map setTerrain:TERRAIN_PLAINS atX:i andY:j];
                    break;
                case pMoor:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pSwamp1:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pRainforest:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_FOREST atX:i andY:j];
                    break;
                case pSwamp2:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pJungle: // 23
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_FOREST atX:i andY:j];
                    break;
                case pMeadow5:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pWildDesert:
                    [self.map setTerrain:TERRAIN_DESERT atX:i andY:j];
                    break;
                case pDesert:
                    [self.map setTerrain:TERRAIN_DESERT atX:i andY:j];
                    break;
                case pLake:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    break;
                case pHill:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_HILL atX:i andY:j];
                    break;
                case pLowMountain:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_HILL atX:i andY:j];
                    break;
                case pMidMountain:
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_MOUNTAIN atX:i andY:j];
                    break;
                case pHighMountain: // 31
                    [self.map setTerrain:TERRAIN_GRASS atX:i andY:j];
                    [self.map addFeature:FEATURE_MOUNTAIN atX:i andY:j];
                    break;
            }
        }
    }
}

// generate data out of pseudo-types
- (void)modifyWorkWithVegetation:(Array2D *)vegetationMap
{
    for (int i = 0; i < self.map.size.width; i++) {
        for (int j = 0; j < self.map.size.height; j++) {
            if ([self.tmpMap intAtX:i andY:j] == pSpPlain) {
                float vegetationValue = [vegetationMap floatAtX:i andY:j];
                float newPlainValue = [self generatePlainFromVegetation:vegetationValue andLatitude:j];
                [self.tmpMap setInt:newPlainValue atX:i andY:j];
            } else if ([self.tmpMap intAtX:i andY:j] == pSpHill) {
                float vegetationValue = [vegetationMap floatAtX:i andY:j];
                float newPlainValue = [self generateHillsFromVegetation:vegetationValue andLatitude:j];
                [self.tmpMap setInt:newPlainValue atX:i andY:j];
            }
        }
    }
}

- (Climate)climateForLatitude:(int)latitude
{
    int borderPolar = self.map.size.height * latitudePolar / 200;
    int borderSubPolar = self.map.size.height * latitudeSubPolar / 200;
    int borderTemperated = self.map.size.height * latitudeGemaessigt / 200;
    int borderSubTropic = self.map.size.height * latitudeSubTropic / 200;
    
    if ((latitude < borderPolar) || (latitude > (self.map.size.height-borderPolar))) {
        return cPolar;
    }
    if ((latitude < borderSubPolar) || (latitude > (self.map.size.height-borderSubPolar))) {
        return cSubPolar;
    }
    if ((latitude < borderTemperated) || (latitude > (self.map.size.height-borderTemperated))) {
        return cGemaessigt;
    }
    if ((latitude < borderSubTropic) || (latitude > (self.map.size.height-borderSubTropic))) {
        return cSubTropen;
    }
    return cTropen;
}

#define PERCENT (rand() % 100)

- (int)generatePlainFromVegetation:(float)vegetation andLatitude:(int)latitude
{
    switch ([self climateForLatitude:latitude]) {
        case cPolar:
            if(PERCENT <= 90) {
                return pGlacier;
            } else {
                return pWasteland;
            }
            break;
        case cSubPolar:
            if (PERCENT > 90) {
                return pWasteland;
            } else {
                if (PERCENT < 33) {
                    if (vegetation > 2) {
                        return pMoor;
                    } else {
                        return pSwamp1;
                    }
                } else {
                    if (vegetation > 2) {
                        if (PERCENT > 90) {
                            return pConiferous;
                        } else {
                            return pTaiga;
                        }
                    } else if (PERCENT > 90) {
                        return pMeadow1;
                    } else {
                        return pTundra;
                    }
                }
            }
            break;
        case cGemaessigt:
            if (rand()%100 > 66) {
                if (vegetation < 2) {
                    return pConiferous;
                } else {
                    return pMeadow1;
                }
            } else if (PERCENT > 50) {
                if (vegetation < 2) {
                    return pMixedforest;
                } else {
                    return pMeadow2;
                }
            } else {
                if (vegetation < 2) {
                    return pDeciduous;
                } else {
                    return pMeadow3;
                }
            }
            break;
        case cSubTropen:
            if (PERCENT > 66) {
                if (PERCENT > 50) {
                    if (vegetation < 2) {
                        return pDeciduous;
                    } else {
                        return pMeadow3;
                    }
                } else {
                    if (vegetation < 2) {
                        return pBushes;
                    } else {
                        return pMeadow4;
                    }
                }
            } else {
                if (PERCENT > 50) {
                    if (PERCENT > 66) {
                        if (vegetation < 2) {
                            return pSavanne;
                        } else {
                            return pSteppe;
                        }
                    } else {
                        if (vegetation < 2) {
                            return pRainforest;
                        } else {
                            return pSwamp2;
                        }
                    }
                } else {
                    if (vegetation < 2) {
                        return pJungle;
                    } else {
                        return pMeadow5;
                    }
                }
            }
            break;
        case cTropen:
            if (PERCENT > 50) {
                if (PERCENT > 50) {
                    if (vegetation < 2) {
                        return pBushes;
                    } else {
                        return pMeadow4;
                    }
                } else if (vegetation < 2) {
                    return pSavanne;
                } else {
                    return pSteppe;
                }
            } else if (PERCENT < 33) {
                if (vegetation < 2) {
                    return pRainforest;
                } else {
                    return pSwamp2;
                }
            } else if (PERCENT < 50) {
                if (vegetation < 2) {
                    return pJungle;
                } else {
                    return pMeadow5;
                }
            } else if (vegetation < 2) {
                return pWildDesert;
            } else {
                return pDesert;
            }
            break;
        default:
            return pMeadow1;
    }
}

- (int)generateHillsFromVegetation:(float)vegetation andLatitude:(int)latitude
{
    switch ([self climateForLatitude:latitude]) {
        case cPolar:
            if(PERCENT <= 90) {
                return pGlacier;
            } else {
                return pWasteland;
            }
            break;
        case cSubPolar:
            if (PERCENT > 90) {
                return pWasteland;
            } else {
                if (PERCENT < 33) {
                    if (vegetation>2) {
                        return pMoor;
                    } else {
                        return pSwamp1;
                    }
                } else {
                    if (vegetation > 2) {
                        if (PERCENT > 90) {
                                return pConiferous;
                        } else {
                            return pTaiga;
                        }
                    } else if (PERCENT > 90) {
                        return pMeadow1;
                    } else {
                        return pTundra;
                    }
                }
            }
            //Sumpf & Moor
            break;
        case cGemaessigt:
            if (PERCENT > 66) {
                if (vegetation < 2) {
                    return pConiferous;
                } else {
                    return pMeadow1;
                }
            } else if (PERCENT > 50) {
                if (vegetation < 2) {
                    return pMixedforest;
                } else {
                    return pMeadow2;
                }
            } else if (vegetation < 2) {
                return pDeciduous;
            } else {
                return pMeadow3;
            }
            break;
        case cSubTropen:
            if (PERCENT > 66) {
                if (PERCENT > 50) {
                    if (vegetation < 2) {
                        return pDeciduous;
                    } else {
                        return pMeadow3;
                    }
                } else if (vegetation < 2) {
                    return pBushes;
                } else {
                    return pMeadow4;
                }
            } else if (PERCENT > 50) {
                if ( PERCENT >66) {
                    if (vegetation<2) {
                        return pSavanne;
                    } else {
                        return pSteppe;
                    }
                } else if (vegetation<2) {
                    return pRainforest;
                } else {
                    return pSwamp2;
                }
            } else if (vegetation<2) {
                return pJungle;
            } else {
                return pMeadow5;
            }
            break;
        case cTropen:
            if (PERCENT > 50) {
                if (PERCENT > 50) {
                    if (vegetation < 2) {
                        return pBushes;
                    } else {
                        return pMeadow4;
                    }
                } else if (vegetation < 2) {
                    return pSavanne;
                } else {
                    return pSteppe;
                }
            } else if (PERCENT < 33) {
                if (vegetation < 2) {
                    return pRainforest;
                } else {
                    return pSwamp2;
                }
            } else if (PERCENT < 50) {
                if (vegetation < 2) {
                    return pJungle;
                } else {
                    return pMeadow5;
                }
            } else if (vegetation < 2) {
                return pWildDesert;
            } else {
                return pDesert;
            }
            break;
        default:
            return pMeadow1;
    }
    
    return pMeadow1;
}

- (void)setOceansAndMountains
{
    for (int i = 0; i < self.map.size.width; i++) {
        for (int j = 0; j < self.map.size.height; j++) {
            int height = [self.heightMap valueAtX:i andY:j];
            if (height <= kWaterDepth) {
                // Sea
                if (height <= kDeepSea) {
                    [self.tmpMap setFloat:pDeepSea atX:i andY:j];
                } else if (height <= kNormalSea) {
                    [self.tmpMap setFloat:pNormalSea atX:i andY:j];
                } else if ([self climateForLatitude:j] == cPolar) {
                    [self.tmpMap setFloat:pIceberg atX:i andY:j];
                } else {
                    [self.tmpMap setFloat:pFlatSea atX:i andY:j];
                }
            } else {
                // Continent
                if (height >= kHighMountain) {
                    [self.tmpMap setFloat:pHighMountain atX:i andY:j];
                } else if (height >= kMidMountain) {
                    [self.tmpMap setFloat:pMidMountain atX:i andY:j];
                } else if (height >= kLowMountain) {
                    [self.tmpMap setFloat:pLowMountain atX:i andY:j];
                } else if (height >= kHills) {
                    [self.tmpMap setFloat:pHill atX:i andY:j];
                } else if (height <= kFlatLand) {
                    [self.tmpMap setFloat:pSpPlain atX:i andY:j];
                } else {
                    [self.tmpMap setFloat:pSpHill atX:i andY:j];
                }
            }
        }
    }
}

- (void)checkOcean
{
    for (int i = 0; i < self.map.size.width; i++) {
        for (int j = 0; j < self.map.size.height; j++) {
            if ([self isOceanAtX:i andY:j]) {
                int max = [self.tmpMap maximumIntOnHexAtX:i andY:j withDefault:0];
                if ((max >= pGlacier) && ([self.tmpMap intAtX:i andY:j] < pFlatSea)) {
                    [self.tmpMap setInt:pFlatSea atX:i andY:j];
                } else if ((max >= pFlatSea) && ([self.tmpMap intAtX:i andY:j] < pNormalSea)) {
                    [self.tmpMap setInt:pNormalSea atX:i andY:j];
                }
            }
        }
    }
    
    for (int i = 0; i < self.map.size.width; i++) {
        for (int j = 0; j < self.map.size.height; j++) {
            if ([self isOceanAtX:i andY:j]) {
                float max = [self.tmpMap maximumIntOnHexAtX:i andY:j withDefault:0.0f];
                if ((max >= pGlacier) && ([self.tmpMap intAtX:i andY:j] < pFlatSea)) {
                    [self.tmpMap setInt:pFlatSea atX:i andY:j];
                } else if ((max >= pFlatSea) && ([self.tmpMap intAtX:i andY:j] < pNormalSea)) {
                    [self.tmpMap setInt:pNormalSea atX:i andY:j];
                }
            }
        }
    }
}

- (BOOL)isOceanAt:(HexPoint *)h
{
    if (![self.map isValidAt:h]) {
        return NO;
    }
    return [self isOceanAtX:h.x andY:h.y];
}

- (BOOL)isOceanAtX:(int)x andY:(int)y
{
    if (![self.map isValidAtX:x andY:y]) {
        return NO;
    }
    
    return [self.tmpMap intAtX:x andY:y] < pGlacier;
}

- (BOOL)isHillOrMountainAtX:(int)x andY:(int)y
{
    if (![self.map isValidAtX:x andY:y]) {
        return NO;
    }
    
    return [self.tmpMap intAtX:x andY:y] >= pHill;
}

- (void)generateIslands
{
    for (int count = 0; count < kNumberOfIslands;) {
        int nx = RandomUInt() % (int)self.map.size.width;
        int ny = RandomUInt() % (int)self.map.size.height;
        
        //check for flatsea, if is, make Island
        if ([self.tmpMap intAtX:nx andY:ny] == pFlatSea) {
            [self.tmpMap setInt:pIsland atX:nx andY:ny];
            count++; 	
        }
    }
}

- (void)postExecute:(NSInteger)result
{
    NSLog(@"Finished with status: %ld", result);
    if (result == 1) {
        
    } else {
        
    }
}

@end
