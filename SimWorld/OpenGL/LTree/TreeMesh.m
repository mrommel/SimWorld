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
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    int _numVertices;
    int _numTriangles;
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
    GLKVector3 min = GLKVector3Make(10000, 10000, 10000);
    GLKVector3 max = GLKVector3Make(-10000, -10000, -10000);
    
    // Create lists for vertices and indices
    NSMutableArray *vertices = [[NSMutableArray alloc] init]; // TreeVertex
    NSMutableArray *indices = [[NSMutableArray alloc] init]; // int
    
    // Absolute transformation of branches
    NSMutableArray *transforms = [[NSMutableArray alloc] initWithCapacity:skeleton.branches.count]; // GLKMatrix4
    [skeleton copyAbsoluteBranchTransformsTo:transforms];
    
    // Branch topological distances from root
    NSMutableArray *distances = [[NSMutableArray alloc] initWithCapacity:skeleton.branches.count]; // float
    [skeleton longestBranching:distances];
    
    //
    //  Create vertices and indices
    //
    for (int i = 0; i < skeleton.branches.count; i++)
    {
        int bottomRadials = [self radialSegmentsBottomFromIndex:i andSkeleton:skeleton];
        
        // Add bottom vertices
        int parentIndex = [skeleton branchAtIndex:i].parentIndex;
        int bottomIndex = vertices.count;
        CC3GLMatrix *bottomTransform = [transforms objectAtIndex:i];
        CC3GLMatrix *parentTransform = [transforms objectAtIndex:parentIndex];
        if (parentIndex != -1 && [skeleton branchAtIndex:i].parentPosition > 0.99f && CC3VectorDot([bottomTransform extractUpDirection], [parentTransform extractUpDirection]) > 0.7f)
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
        int parentBoneIndex = (parentIndex == -1? [skeleton branchAtIndex:i].boneIndex : [skeleton branchAtIndex:parentIndex].boneIndex);
        int branchBoneIndex = [skeleton branchAtIndex:i].boneIndex;
        
        [self addCircleVerticesWithTransform:bottomTransform andRadius:[skeleton branchAtIndex:i].startRadius andSegments:bottomRadials andTextureY:ty andTextureStartX:0.0f andTextureSpanX:txspan andVertices:vertices andBone1:parentBoneIndex andBone2:parentBoneIndex];
        
        // Add top vertices
        int topRadials = [self radialSegmentsTopFromIndex:i andSkeleton:skeleton];
        NSUInteger topIndex = vertices.count;
        CC3GLMatrix *topTransform = [transforms objectAtIndex:i];
        [topTransform translateBy:CC3VectorScaleUniform([topTransform extractUpDirection], [skeleton branchAtIndex:i].length)];
        
        ty = ty + [skeleton branchAtIndex:i].length / skeleton.textureHeight;
        txspan = 0.25f + 0.75f * [skeleton branchAtIndex:i].endRadius / skeleton.trunkRadius;
        
        [self addCircleVerticesWithTransform:topTransform andRadius:[skeleton branchAtIndex:i].endRadius andSegments:topRadials andTextureY:ty andTextureStartX:0.0f andTextureSpanX:txspan andVertices:vertices andBone1:branchBoneIndex andBone2:branchBoneIndex];
        
        // Add indices
        [self addCylinderIndicesWithBottomIndex:bottomIndex andBottomVertices:bottomRadials andTopIndex:topIndex andTopVertices:topRadials andIndices:indices];
        
        // Updates bounds
        SetMin(&min, [bottomTransform extractTranslation]);
        SetMin(&min, [topTransform extractTranslation]);
        SetMax(&max, [bottomTransform extractTranslation]);
        SetMax(&max, [topTransform extractTranslation]);
    }
    
    [self populateWithNumberOfVertices:vertices.count andNumberOfIndices:indices.count];
    
    // fill vertices
    for(int i = 0; i < vertices.count; ++i) {
        TreeVertex *vertex = [vertices objectAtIndex:i];
        [self setVertexAt:i andX:vertex.position.x andY:vertex.position.y andZ:vertex.position.z andTextureX:vertex.textureCoordinate.x andTextureY:vertex.textureCoordinate.y];
    }
    
    // fill indices
    for(int i = 0; i < indices.count; ++i) {
        [self setIndexAt:i toIndex:[[indices objectAtIndex:i] intValue]];
    }
    
    // @TODO: Set the bounding sphere
    // boundingSphere.Center = (min + max) / 2.0f;
    // boundingSphere.Radius = (max - min).Length() / 2.0f;
}

- (int)radialSegmentsBottomFromIndex:(int)index andSkeleton:(TreeSkeleton *)skeleton
{
    float ratio = [skeleton.branches objectAtIndex:index].startRadius / [skeleton.branches objectAtIndex:0].startRadius;
    return 3 + (int)(ratio * (maxRadialSegments - 3) + 0.50f);
}

- (int)radialSegmentsTopFromIndex:(int)index andSkeleton:(TreeSkeleton *)skeleton
{
    float ratio = [skeleton.branches objectAtIndex:index] / [skeleton.branches objectAtIndex:0].StartRadius;
    return 3 + (int)(ratio * (maxRadialSegments - 3) + 0.50f);
}

- (void)addCircleVerticesWithTransform:(CC3GLMatrix*)transform
                             andRadius:(float)radius andSegments:(int)segments
                           andTextureY:(float)textureY
                      andTextureStartX:(float)textureStartX
                       andTextureSpanX:(float)textureSpanX
                           andVertices:(NSMutableArray*)vertices
                              andBone1:(int)bone1
                              andBone2:(int)bone2
{
    for (int i = 0; i < segments + 1; i++)
    {
        double angle = i / (double)(segments) * M_PI * 2.0;
        CC3Vector dir = CC3VectorMake(cosf(angle), 0, sinf(angle));
        
        //         Vector3.TransformNormal(ref dir, ref transform, out dir);
        CC3Vector dirNormal = CC3VectorNormalize(dir);
        dir = [transform transformDirection:dirNormal];

        float tx = textureStartX + (i / (float)(segments)) * textureSpanX;
        
        [vertices addObject:[[TreeVertex alloc] initWithTranslation:CC3VectorAdd([transform extractTranslation], CC3VectorScaleUniform(dir, radius)) andDirection:dir andTextureCoords:CC2VectorMake(tx, textureY) andBone1:bone1 andBone2:bone2]];
    }
}

- (void)addCylinderIndicesWithBottomIndex:(int)bottomIndex
                           andBottomVertices:(int)numBottomVertices
                                 andTopIndex:(int)topIndex
                              andTopVertices:(int)numTopVertices
                                  andIndices:(NSMutableArray *)indices
{
    int bi = 0; // Bottom index
    int ti = 0; // Top index
    while (bi < numBottomVertices || ti < numTopVertices)
    {
        if (bi * numTopVertices < ti * numBottomVertices)
        {
            // Move bottom index forward
            [indices addObject:[NSNumber numberWithInt:(bottomIndex + bi + 1)]];
            [indices addObject:[NSNumber numberWithInt:(topIndex + ti)]];
            [indices addObject:[NSNumber numberWithInt:(bottomIndex + bi)]];
            
            bi++;
        }
        else
        {
            // Move top index forward
            [indices addObject:[NSNumber numberWithInt:(bottomIndex + bi)]];
            [indices addObject:[NSNumber numberWithInt:(topIndex + ti + 1)]];
            [indices addObject:[NSNumber numberWithInt:(topIndex + ti)]];
            
            ti++;
        }
    }
}

- (void)draw
{
    
}

@end
