//
//  TreeMesh.m
//  SimWorld
//
//  Created by Michael Rommel on 09.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeMesh.h"

#import "TreeSkeleton.h"
#import <GLKit/GLKit.h>
#import "TreeBranch.h"
#import <math.h>

@interface TreeMesh() {
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    int _numVertices;
    int _numtriangles;
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
            //GLKVector3 childDir = Vector3.Transform(kCC3VectorUnitXPositive, [skeleton branchAtIndex:i].rotation);
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
            
            bottomTransform.Right = right;
            bottomTransform.Backward = back;
        }
        
        // Texture coordinates
        float ty = (distances[i] - skeleton.Branches[i].Length) / skeleton.TextureHeight;
        float txspan = 0.25f + 0.75f * skeleton.Branches[i].StartRadius / skeleton.TrunkRadius;
        
        // Bones
        int parentBoneIndex = (parentIndex == -1? skeleton.Branches[i].BoneIndex : skeleton.Branches[parentIndex].BoneIndex);
        int branchBoneIndex = skeleton.Branches[i].BoneIndex;
        
        AddCircleVertices(ref bottomTransform, skeleton.Branches[i].StartRadius, bottomRadials, ty, 0.0f, txspan, vertices, parentBoneIndex, parentBoneIndex);
        
        // Add top vertices
        int topRadials = GetRadialSegmentsTop(i, skeleton);
        int topIndex = vertices.Count;
        Matrix topTransform = transforms[i];
        topTransform.Translation += topTransform.Up * skeleton.Branches[i].Length;
        
        ty = ty + skeleton.Branches[i].Length / skeleton.TextureHeight;
        txspan = 0.25f + 0.75f * skeleton.Branches[i].EndRadius / skeleton.TrunkRadius;
        
        AddCircleVertices(ref topTransform, skeleton.Branches[i].EndRadius, topRadials, ty, 0.0f, txspan, vertices, branchBoneIndex, branchBoneIndex);
        
        // Add indices
        AddCylinderIndices(bottomIndex, bottomRadials, topIndex, topRadials, indices);
        
        // Updates bounds
        SetMin(ref min, bottomTransform.Translation);
        SetMin(ref min, topTransform.Translation);
        SetMax(ref max, bottomTransform.Translation);
        SetMax(ref max, topTransform.Translation);
    }
    
    numvertices = vertices.Count;
    numtriangles = indices.Count / 3;
    
    // Create the buffers
    vbuffer = new VertexBuffer(device, TreeVertex.VertexDeclaration, vertices.Count, BufferUsage.None);
    vbuffer.SetData<TreeVertex>(vertices.ToArray());
    
    if (vertices.Count > 0xFFFF)
    {
        ibuffer = new IndexBuffer(device, IndexElementSize.ThirtyTwoBits, indices.Count, BufferUsage.None);
        ibuffer.SetData<int>(indices.ToArray());
    }
    else
    {
        ibuffer = new IndexBuffer(device, IndexElementSize.SixteenBits, indices.Count, BufferUsage.None);
        ibuffer.SetData<short>(Create16BitArray(indices));
    }
    
    // Set the bounding sphere
    boundingSphere.Center = (min + max) / 2.0f;
    boundingSphere.Radius = (max - min).Length() / 2.0f;
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

- (void)draw
{
    
}

@end
