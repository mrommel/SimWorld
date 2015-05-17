//
//  HexagonMapMesh.h
//  SimWorld
//
//  Created by Michael Rommel on 16.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "Mesh.h"
#import "HexagonMapItem.h"
#import "TextureAtlas.h"
#import "HexagonMap.h"

@protocol HexagonMapMeshDelegate;

@interface HexagonMapMesh : Mesh

@property (nonatomic, assign) GLuint riverTexture;

- (id)initWithMap:(HexagonMap *)map andTerrainAtlas:(TextureAtlas *)textureAtlas andRiverAtlas:(TextureAtlas *)riverAtlas;
//- (id)initWithMap:(HexagonMap *)map andRiverAtlas:(TextureAtlas *)textureAtlas;

@end

@protocol HexagonMapMeshDelegate <NSObject>

- (HexagonMapItem *)hexagonMapMesh:(HexagonMapMesh *)mesh didChooseX:(int)x andY:(int)y;

@end
