//
//  TreeLeafCloud.m
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeLeafCloud.h"

#import "TreeSkeleton.h"
#import "CC3GLMatrix+Extension.h"
#import "TreeLeaf.h"
#import "TreeBranch.h"
#import "NSArray+Extensions.h"

@implementation TreeLeafCloud

- (id)initWithTreeSkeleton:(TreeSkeleton *)skeleton
{
    self = [super init];
    
    if (self) {
        if (skeleton.leaves.count == 0) {
            return nil;
        }
        
        NSMutableArray *transforms = [[NSMutableArray alloc] initWithCapacity:skeleton.branches.count];
        [transforms fillWith:[CC3GLMatrix matrix] andTimes:skeleton.branches.count];
        [skeleton copyAbsoluteBranchTransformsTo:transforms];
        
        CC3Vector center = kCC3VectorZero;
        for (int i = 0; i < skeleton.leaves.count; i++) {
            NSInteger parentIndex = [skeleton leaveAtIndex:i].parentIndex;
            center = CC3VectorAdd(center, [[transforms matrixAtIndex:parentIndex] extractTranslation]);
        }
        center = CC3VectorScaleUniform(center, 1.0f / (float)skeleton.leaves.count);
        
        //LeafVertex[] vertices = new LeafVertex[skeleton.Leaves.Count * 4];
        //short[] indices = new short[skeleton.Leaves.Count * 6];
        [self populateWithNumberOfVertices:(skeleton.leaves.count * 4) andNumberOfIndices:(skeleton.leaves.count * 6)];
        
        int vindex = 0;
        int iindex = 0;
        
        self.boundingSphere = CC3BoundingSphereMakeFromCenter(center, 0);
        
        for (TreeLeaf *leaf in skeleton.leaves) {
            // Get the position of the leaf
            CC3Vector position = CC3VectorAdd([[transforms matrixAtIndex:leaf.parentIndex] extractTranslation], CC3VectorScaleUniform([[transforms matrixAtIndex:leaf.parentIndex] extractUpDirection], [skeleton branchAtIndex:leaf.parentIndex].length));
            if (skeleton.leafAxis != nil) {
                position = CC3VectorAdd(position, CC3VectorScaleUniform(skeleton.leafAxis.value, leaf.axisOffset));
            }
            
            // Orientation
            CC3Vector2 right = CC3Vector2Make((float)cos(leaf.rotation), (float)sin(leaf.rotation));
            CC3Vector2 up = CC3Vector2Make(-right.y, right.x);
            
            // Scale vectors by size
            right = CC3Vector2ScaleUniform(right, leaf.size.x);
            up = CC3Vector2ScaleUniform(up, leaf.size.y);
            
            // Choose a normal vector for lighting calculations
            float distanceFromCenter = CC3VectorDistance(position, center);
            CC3Vector normal = CC3VectorScaleUniform(CC3VectorDifference(position, center), 1.0f / distanceFromCenter); // normalize the normal
            
            //                    0---1
            // Vertex positions:  | \ |
            //                    3---2
            // TODO: leaf.BoneIndex, normal
            int vidx = vindex;
            [self setVertexAt:(vindex++) andX:position.x andY:position.y andZ:position.z andTextureX:0 andTextureY:0 andColorA:leaf.color.a andColorR:leaf.color.r andColorG:leaf.color.g andColorB:leaf.color.b];
            [self setVertexAt:(vindex++) andX:position.x andY:position.y andZ:position.z andTextureX:0 andTextureY:0 andColorA:leaf.color.a andColorR:leaf.color.r andColorG:leaf.color.g andColorB:leaf.color.b];
            [self setVertexAt:(vindex++) andX:position.x andY:position.y andZ:position.z andTextureX:0 andTextureY:0 andColorA:leaf.color.a andColorR:leaf.color.r andColorG:leaf.color.g andColorB:leaf.color.b];
            [self setVertexAt:(vindex++) andX:position.x andY:position.y andZ:position.z andTextureX:0 andTextureY:0 andColorA:leaf.color.a andColorR:leaf.color.r andColorG:leaf.color.g andColorB:leaf.color.b];
            //vertices[vindex++] = new LeafVertex(position, new Vector2(0, 0), -right + up, leaf.Color, leaf.BoneIndex, normal);
            //vertices[vindex++] = new LeafVertex(position, new Vector2(1, 0), right + up, leaf.Color, leaf.BoneIndex, normal);
            //vertices[vindex++] = new LeafVertex(position, new Vector2(1, 1), right - up, leaf.Color, leaf.BoneIndex, normal);
            //vertices[vindex++] = new LeafVertex(position, new Vector2(0, 1), -right - up, leaf.Color, leaf.BoneIndex, normal);
            
            // Add indices
            [self setTriangleAt:iindex++ withIndex1:vidx andIndex2:(vidx + 1) andIndex3:(vidx + 2)];
            [self setTriangleAt:iindex++ withIndex1:vidx andIndex2:(vidx + 2) andIndex3:(vidx + 3)];
            
            //[self setTriangleAt:(iindex++) withIndex1:(vidx) andIndex2:(vidx + 2) andIndex3:(vidx + 3)];
            
            // Update the bounding sphere
            float size = CC3Vector2Length(leaf.size) / 2.0f;
            self.boundingSphere = CC3BoundingSphereMakeFromCenter(self.boundingSphere.center, MAX(self.boundingSphere.radius, distanceFromCenter + size));
        }
        
        // Create the buffers
        //vbuffer = new VertexBuffer(device, LeafVertex.VertexDeclaration, vertices.Length, BufferUsage.None);
        //vbuffer.SetData<LeafVertex>(vertices);
        
        //ibuffer = new IndexBuffer(device, IndexElementSize.SixteenBits, indices.Length, BufferUsage.None);
        //ibuffer.SetData<short>(indices);
        
        // Remember the number of leaves
        // TODO numleaves = skeleton.Leaves.Count;
    }
    
    return self;
}

@end
