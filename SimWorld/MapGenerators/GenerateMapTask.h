//
//  GenerateMapTask.h
//  SimWorld
//
//  Created by Michael Rommel on 06.01.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "AsyncTask.h"

#import "HexagonMap.h"
#import "Array2D.h"
#import "HeightMap.h"

#define kParamNumberOfLakes         @"kParamNumberOfLakes"
#define kParamNumberOfRivers        @"kParamNumberOfRivers"

#define kNumberOfRivers             20
#define kNumberOfLakes              20
#define kNumberOfIslands            20

#define kNoRivers                   -1
#define kNoLakes                    -1

@interface GenerateMapTask : AsyncTask {
    
}

@property (nonatomic,retain) HexagonMap *map;
@property (nonatomic,retain) Array2D *tmpMap;
@property (nonatomic,retain) HeightMap *heightMap;

@end
