//
//  TreeMesh.m
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeMesh.h"

#import <GLKit/GLKit.h>
#import <math.h>

#import "TreeSkeleton.h"
#import "TreeBranch.h"
#import "NSArray+Extensions.h"
#import "CC3GLMatrix+Extension.h"
#import "TreeVertex.h"

@interface TreeMesh() {
    int _maxRadialSegments;
}

@end

@implementation TreeMesh

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton
{
    _maxRadialSegments = 8;
    
    self = [super init];
    
    if (self) {
        [self loadFromSkeleton:skeleton];
    }
    
    return self;
}

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton andNumberOfRadialSegments:(int)numberOfRadialSegments
{
    _maxRadialSegments = numberOfRadialSegments;
    
    self = [super init];
    
    if (self) {
        [self loadFromSkeleton:skeleton];
    }
    
    return self;
}

- (void)loadFromSkeleton:(TreeSkeleton *)skeleton
{
    NSAssert(skeleton.branches.count > 0, @"Tree skeleton had no branches");
    NSAssert(_maxRadialSegments > 2, @"Tree must have at least 3 radial segments");
    
    // min and max keep track of the mesh's bounding box.
    CC3Vector min = CC3VectorMake(10000, 10000, 10000);
    CC3Vector max = CC3VectorMake(-10000, -10000, -10000);
    
    // Create lists for vertices and indices
    NSMutableArray *vertices = [[NSMutableArray alloc] init]; // TreeVertex
    NSMutableArray *indices = [[NSMutableArray alloc] init]; // int
    
    // Absolute transformation of branches
    NSMutableArray *transforms = [[NSMutableArray alloc] initWithCapacity:skeleton.branches.count]; // CC3GLMatrix
    [transforms fillWith:[CC3GLMatrix matrix] forAmount:skeleton.branches.count];
    [skeleton copyAbsoluteBranchTransformsTo:transforms];
    
    // Branch topological distances from root
    NSMutableArray *distances = [[NSMutableArray alloc] initWithCapacity:skeleton.branches.count]; // float
    [distances fillWithFloat:0.0f forAmount:skeleton.branches.count];
    [skeleton longestBranching:distances];
    
    //
    //  Create vertices and indices
    //
    for (int i = 0; i < skeleton.branches.count; i++)
    {
        int bottomRadials = [self radialSegmentsBottomFromIndex:i andSkeleton:skeleton];
        
        // Add bottom vertices
        NSInteger parentIndex = [skeleton branchAtIndex:i].parentIndex;
        NSUInteger bottomIndex = vertices.count;
        CC3GLMatrix *bottomTransform = [transforms objectAtIndex:i];

        if (parentIndex != -1 && [skeleton branchAtIndex:i].parentPosition > 0.99f && CC3VectorDot([bottomTransform extractUpDirection], [[transforms objectAtIndex:parentIndex] extractUpDirection]) > 0.7f)
        {
            bottomTransform = [transforms objectAtIndex:parentIndex];
            [bottomTransform translateBy: CC3VectorScaleUniform([bottomTransform extractUpDirection], [skeleton branchAtIndex:parentIndex].length)];
            
            // Rotate bottomTransform to the best fit to avoid twisting
            CC3Vector childDir = [[skeleton branchAtIndex:i].rotation transformDirection:kCC3VectorUnitXPositive];
            
            float maxdot = -2.0f;
            double bestangle = 0.0;
            for (int j = 0; j < bottomRadials; j++)
            {
                double angle = j / (double)bottomRadials * M_PI * 2.0;
                CC3Vector vec = CC3VectorMake((float)cos(angle), 0, (float)sin(angle));
                
                float dot = CC3VectorDot(childDir, vec);
                if (dot > maxdot)
                {
                    maxdot = dot;
                    bestangle = angle;
                }
            }
            
            float cos = cosf(bestangle);
            float sin = sinf(bestangle);
            CC3Vector right = CC3VectorAdd(CC3VectorScaleUniform([bottomTransform extractRightDirection], cos), CC3VectorScaleUniform([bottomTransform extractForwardDirection], -sin));
            CC3Vector back = CC3VectorAdd(CC3VectorScaleUniform([bottomTransform extractRightDirection], -sin), CC3VectorScaleUniform([bottomTransform extractForwardDirection], -cos));
            
            [bottomTransform setRightDirection:right];
            [bottomTransform setBackwardDirection:back];
        }
        
        // Texture coordinates
        float ty = ([distances floatAtIndex:i] - [skeleton branchAtIndex:i].length) / skeleton.textureHeight;
        float txspan = 0.25f + 0.75f * [skeleton branchAtIndex:i].startRadius / skeleton.trunkRadius;
        
        // Bones
        NSUInteger parentBoneIndex = (parentIndex == -1? [skeleton branchAtIndex:i].boneIndex : [skeleton branchAtIndex:parentIndex].boneIndex);
        NSUInteger branchBoneIndex = [skeleton branchAtIndex:i].boneIndex;
        
        [self addCircleVerticesWithTransform:bottomTransform andRadius:[skeleton branchAtIndex:i].startRadius andSegments:bottomRadials andTextureY:ty andTextureStartX:0.0f andTextureSpanX:txspan andVertices:vertices andBone1:parentBoneIndex andBone2:parentBoneIndex];
        
        // Add top vertices
        NSUInteger topRadials = [self radialSegmentsTopFromIndex:i andSkeleton:skeleton];
        NSUInteger topIndex = vertices.count;
        CC3GLMatrix *topTransform = [transforms objectAtIndex:i];
        [topTransform translateBy:CC3VectorScaleUniform([topTransform extractUpDirection], [skeleton branchAtIndex:i].length)];
        
        ty = ty + [skeleton branchAtIndex:i].length / skeleton.textureHeight;
        txspan = 0.25f + 0.75f * [skeleton branchAtIndex:i].endRadius / skeleton.trunkRadius;
        
        [self addCircleVerticesWithTransform:topTransform andRadius:[skeleton branchAtIndex:i].endRadius andSegments:topRadials andTextureY:ty andTextureStartX:0.0f andTextureSpanX:txspan andVertices:vertices andBone1:branchBoneIndex andBone2:branchBoneIndex];
        
        // Add indices
        [self addCylinderIndicesWithBottomIndex:bottomIndex andBottomVertices:bottomRadials andTopIndex:topIndex andTopVertices:topRadials andIndices:indices];
        
        // Updates bounds
        min = CC3VectorMinimize(min, [bottomTransform extractTranslation]);
        min = CC3VectorMinimize(min, [topTransform extractTranslation]);
        max = CC3VectorMaximize(max, [bottomTransform extractTranslation]);
        max = CC3VectorMaximize(max, [topTransform extractTranslation]);
    }
    
    [self populateWithNumberOfVertices:vertices.count andNumberOfIndices:indices.count];
    
    // fill vertices
    for(int i = 0; i < vertices.count; ++i) {
        TreeVertex vertex = [vertices treeVertexAtIndex:i];
        [self setVertexAt:i andX:vertex.Position[0] andY:vertex.Position[1] andZ:vertex.Position[2]
               andNormalX:vertex.Normal[0] andNormalY:vertex.Normal[1] andNormalZ:vertex.Normal[2]
              andTextureX:vertex.TexCoord[0] andTextureY:vertex.TexCoord[1]
                 andBone1:vertex.Bones[0] andBone2:vertex.Bones[1]];
    }
    
    // fill indices
    for(int i = 0; i < indices.count; ++i) {
        [self setIndexAt:i toIndex:[indices intAtIndex:i]];
    }
    
    // Set the bounding sphere
    self.boundingBox = CC3BoundingBoxFromMinMax(min, max);
}

- (int)radialSegmentsBottomFromIndex:(int)index andSkeleton:(TreeSkeleton *)skeleton
{
    float ratio = [skeleton branchAtIndex:index].startRadius / [skeleton branchAtIndex:0].startRadius;
    return 3 + (int)(ratio * (_maxRadialSegments - 3) + 0.50f);
}

- (int)radialSegmentsTopFromIndex:(int)index andSkeleton:(TreeSkeleton *)skeleton
{
    float ratio = [skeleton branchAtIndex:index].startRadius / [skeleton branchAtIndex:0].startRadius;
    return 3 + (int)(ratio * (_maxRadialSegments - 3) + 0.50f);
}

- (void)addCircleVerticesWithTransform:(CC3GLMatrix*)transform
                             andRadius:(float)radius
                           andSegments:(NSInteger)segments
                           andTextureY:(float)textureY
                      andTextureStartX:(float)textureStartX
                       andTextureSpanX:(float)textureSpanX
                           andVertices:(NSMutableArray*)vertices
                              andBone1:(NSInteger)bone1
                              andBone2:(NSInteger)bone2
{
    for (int i = 0; i < segments + 1; i++)
    {
        double angle = i / (double)(segments) * M_PI * 2.0;
        CC3Vector dir = CC3VectorMake(cosf(angle), 0, sinf(angle));
        CC3Vector dirNormal = CC3VectorNormalize(dir);
        dir = [transform transformDirection:dirNormal];

        float tx = textureStartX + (i / (float)(segments)) * textureSpanX;        
        CC3Vector translation = CC3VectorAdd([transform extractTranslation], CC3VectorScaleUniform(dir, radius));
        //NSLog(@"TreeVertex dir: %@", NSStringFromCC3Vector(dir));
        //NSLog(@"TreeVertex translation: %@", NSStringFromCC3Vector(translation));
        [vertices addTreeVertex:TreeVertexMake(translation, dir, CC3Vector2Make(tx, textureY), (int)bone1, (int)bone2)];
    }
    
    return;
}

- (void)addCylinderIndicesWithBottomIndex:(NSInteger)bottomIndex
                        andBottomVertices:(int)numBottomVertices
                              andTopIndex:(NSUInteger)topIndex
                           andTopVertices:(NSUInteger)numTopVertices
                               andIndices:(NSMutableArray *)indices
{
    NSInteger bi = 0; // Bottom index
    NSInteger ti = 0; // Top index
    while (bi < numBottomVertices || ti < numTopVertices) {
        if (bi * numTopVertices < ti * numBottomVertices) {
            // Move bottom index forward
            [indices addObject:[NSNumber numberWithInteger:(bottomIndex + bi + 1L)]];
            [indices addObject:[NSNumber numberWithInteger:(topIndex + ti)]];
            [indices addObject:[NSNumber numberWithInteger:(bottomIndex + bi)]];
            
            bi++;
        } else {
            // Move top index forward
            [indices addObject:[NSNumber numberWithInteger:(bottomIndex + bi)]];
            [indices addObject:[NSNumber numberWithInteger:(topIndex + ti + 1L)]];
            [indices addObject:[NSNumber numberWithInteger:(topIndex + ti)]];
            
            ti++;
        }
    }
}

- (void)populateWithNumberOfVertices:(NSUInteger)numberOfVertices
                  andNumberOfIndices:(NSUInteger)numberOfIndices
{
    self.vertices = malloc(numberOfVertices * sizeof(TreeVertex));
    self.numberOfVertices = numberOfVertices;
    self.indices = malloc(numberOfIndices * sizeof(Index));
    self.numberOfIndices = numberOfIndices;
}

- (void)setIndexAt:(int)index
           toIndex:(int)indexValue
{
    self.indices[index] = indexValue;
}

- (void)setVertexAt:(int)index
               andX:(float)x andY:(float)y andZ:(float)z
         andNormalX:(float)nx andNormalY:(float)ny andNormalZ:(float)nz
        andTextureX:(float)tx andTextureY:(float)ty
           andBone1:(NSUInteger)bone1 andBone2:(NSUInteger)bone2
{
    self.vertices[index].Position[0] = x;
    self.vertices[index].Position[1] = y;
    self.vertices[index].Position[2] = z;
    self.vertices[index].Normal[0] = nx;
    self.vertices[index].Normal[1] = ny;
    self.vertices[index].Normal[2] = nz;
    self.vertices[index].TexCoord[0] = tx;
    self.vertices[index].TexCoord[1] = ty;
    self.vertices[index].Bones[0] = bone1;
    self.vertices[index].Bones[1] = bone2;
}

- (void)draw
{
    
}

@end
