//
//  TreeCrayon.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCrayon.h"

#import "MiRoStack.h"
#import "TreeSkeleton.h"
#import "TreeContraints.h"
#import "CC3GLMatrix.h"
#import "TreeBone.h"
#import "TreeBranch.h"
#import "CC3GLMatrix+Extension.h"
#import "MathHelper.h"
#import "TreeLeaf.h"    

@interface TreeCrayonState : NSObject

@property (atomic) NSInteger parentIndex;
@property (atomic) float parentPosition;
@property (atomic) float scale;
@property (nonatomic, retain) CC3GLMatrix *rotation;
@property (atomic) int level;
@property (atomic) float radiusScale;
@property (atomic) NSInteger parentBoneIndex;
@property (atomic) int boneLevel;

@end

@implementation TreeCrayonState

@end

@interface TreeCrayon() {
    
}

@property (nonatomic, retain) TreeCrayonState *state;
@property (nonatomic, retain) MiRoStack *stack;
@property (nonatomic, retain) NSMutableArray *branchTransforms; // Matrix
@property (nonatomic, retain) NSMutableArray *boneEndings; // Map from bone index to branch where it was created // int

#define MaxBones 20

@end

@implementation TreeCrayon

- (id)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        self.state = [[TreeCrayonState alloc] init];
        self.state.parentIndex = -1;
        self.state.parentPosition = 1.0f;
        self.state.scale = 1.0f;
        self.state.rotation = [[CC3GLMatrix alloc] initIdentity];
        self.state.level = 1;
        self.state.radiusScale = 1.0f;
        self.state.parentBoneIndex = -1;
        self.state.boneLevel = 0;
        
        self.stack = [[MiRoStack alloc] init];
        
        self.boneLevels = 3;
        
        self.skeleton = [[TreeSkeleton alloc] initWithName:name];
        
        self.branchTransforms = [[NSMutableArray alloc] init];
        self.boneEndings = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (int)level
{
    return self.state.level;
}

- (void)setLevel:(int)level
{
    self.state.level = level;
}

- (float)currentScale
{
    return self.state.scale;
}

- (CC3GLMatrix *)transform
{
    CC3GLMatrix *m = [CC3GLMatrix identity];
    [m populateFromQuaternion:[self.state.rotation extractQuaternion]];
    if (self.state.parentIndex == -1)
        return m;
    
    [m setTranslationY:(self.state.parentPosition * [self.skeleton branchAtIndex:self.state.parentIndex].length)];
    
    // TODO: remove
    if (self.state.parentIndex < self.branchTransforms.count) {
        [m multiplyByMatrix:[self.branchTransforms matrixAtIndex:self.state.parentIndex]];
    }
    return m;
}

- (void)pushState
{
    //NSLog(@"pushState: before depth=%ld", [self stackDepth]);
    TreeCrayonState *newstate = [[TreeCrayonState alloc] init];
    newstate.parentIndex = self.state.parentIndex;
    newstate.parentPosition = self.state.parentPosition;
    newstate.scale = self.state.scale;
    newstate.rotation = [CC3GLMatrix matrixFromGLMatrix:self.state.rotation.glMatrix];
    newstate.level = self.state.level;
    newstate.radiusScale = self.state.radiusScale;
    newstate.parentBoneIndex = self.state.parentBoneIndex;
    newstate.boneLevel = self.state.boneLevel;
    
    [self.stack pushObject:self.state];
    self.state = newstate;
    //NSLog(@"pushState: after depth=%ld", [self stackDepth]);
}

- (void)popState
{
    //NSLog(@"popState: before depth=%ld", [self stackDepth]);
    self.state = [self.stack popObject];
    //NSLog(@"popState: after depth=%ld", [self stackDepth]);
}

- (NSUInteger)stackDepth
{
    return self.stack.count;
}

- (void)executeBoneWithDelta:(int)delta
{
    if ((self.state.boneLevel > self.boneLevels + delta) || (self.skeleton.bones.count == MaxBones)) {
        return;
    }
    
    // Get index of the parent
    NSInteger parent = self.state.parentBoneIndex;
    
    // Get the parent's absolute transform
    CC3GLMatrix *parentTransform = [CC3GLMatrix identity];
    CC3GLMatrix *parentInverseTransform = [CC3GLMatrix identity];
    float parentLength = 0.0f;
    if (parent != -1)
    {
        parentTransform = [self.skeleton boneAtIndex:parent].referenceTransform;
        parentInverseTransform = [self.skeleton boneAtIndex:parent].inverseReferenceTransform;
        parentLength = [self.skeleton boneAtIndex:parent].length;
    }
    
    // Find the starting and ending point of the new bone
    CC3Vector targetLocation = [[self transform] extractTranslation];
    CC3Vector fromLocation = CC3VectorAdd([parentTransform extractTranslation], CC3VectorScaleUniform([parentTransform extractUpDirection], parentLength));
    
    // Direction of the bone's Y-axis
    CC3Vector directionY = CC3VectorNormalize(CC3VectorDifference(targetLocation, fromLocation));
    
    // Choose arbitrary perpendicular X and Z axes
    CC3Vector directionX;
    CC3Vector directionZ;
    if (directionY.y < 0.50f) {
        directionX = CC3VectorNormalize(CC3VectorCross(directionY, kCC3VectorUp));
        directionZ = CC3VectorNormalize(CC3VectorCross(directionX, directionY));
    } else {
        directionX = CC3VectorNormalize(CC3VectorCross(directionY, kCC3VectorBackward));
        directionZ = CC3VectorNormalize(CC3VectorCross(directionX, directionY));
    }
    
    // Construct the absolute rotation of the child
    CC3GLMatrix *childAbsoluteTransform = [CC3GLMatrix identity];
    [childAbsoluteTransform setRightDirection:directionX];
    [childAbsoluteTransform setUpDirection:directionY];
    [childAbsoluteTransform setBackwardDirection:directionZ];
    [childAbsoluteTransform setTranslation:fromLocation];
    
    // Calculate the relative transformation
    CC3GLMatrix *relativeTransformation = [childAbsoluteTransform copyMultipliedBy:parentInverseTransform];
    CC3GLMatrix *rotation = [CC3GLMatrix identity];
    [rotation populateFromQuaternion:[relativeTransformation extractQuaternion]];
    
    // Create the new bone
    TreeBone *bone = [[TreeBone alloc] init];
    bone.referenceTransform = childAbsoluteTransform;
    bone.inverseReferenceTransform = [bone.referenceTransform copyInverted];
    bone.length = CC3VectorDistance(fromLocation, targetLocation);
    bone.rotation = rotation;
    bone.parentIndex = parent;
    bone.stiffness = [self.skeleton branchAtIndex:self.state.parentIndex].startRadius; // 1.0f; // TODO: Set stiffness according to radius
    bone.endBranchIndex = self.state.parentIndex;
    
    // Add the bone to the skeleton
    [self.skeleton addBone:bone];
    
    // Set this bone as the parent
    NSInteger endIndex = (self.state.parentBoneIndex == -1 ? -1 : [self.skeleton boneAtIndex:self.state.parentBoneIndex].endBranchIndex);
    NSInteger boneIndex = self.state.parentBoneIndex = self.skeleton.bones.count - 1L;
    self.state.boneLevel -= delta;
    
    // Update the bone index on branches
    NSInteger branchIndex = self.state.parentIndex;
    while (branchIndex != endIndex) {
        TreeBranch *branch = [self.skeleton branchAtIndex:branchIndex];
        branch.boneIndex = boneIndex;
        [self.skeleton insertBranch:branch atIndex:branchIndex];
        branchIndex = branch.parentIndex;
    }
}

#pragma mark -
#pragma mark TreeCrayon instructions

/// <summary>
/// Moves forward while painting a branch here.
/// </summary>
/// <param name="length">Length of the new branch. The current scale will be applied to this.</param>
/// <param name="radiusEndScale">How much smaller the ending radius should be. The equation is: StartRadius * RadiusEndScale = EndRadius.</param>
/// <remarks>
/// The crayon always moves along its local Y-axis, which is initially upwards.
/// </remarks>
- (void)forwardWithDistance:(float)distance andRadius:(float)radiusEndScale
{
    // Run the constraints
    if (self.constraints != nil && ![self.constraints constrainForwardWithCrayon:self andDistance:&distance andRadiusEndScale:&radiusEndScale]) {
        return;
    }
    
    // Create the branch
    TreeBranch *branch = [[TreeBranch alloc] initWithQuaternion:self.state.rotation
                                                      andLength:distance * self.state.scale
                                                       andStart:[self radiusAtParentIndex:self.state.parentIndex andPosition:self.state.parentPosition] * self.state.radiusScale
                                                         andEnd:[self radiusAtParentIndex:self.state.parentIndex andPosition:self.state.parentPosition] * self.state.radiusScale * radiusEndScale
                                                 andParentIndex:self.state.parentIndex
                                              andParentPosition:self.state.parentPosition];

    branch.boneIndex = self.state.parentBoneIndex;
    [self.skeleton addBranch:branch];
    [self.branchTransforms addObject:[self transform]];
    
    // Set newest branch to parent
    self.state.parentIndex = self.skeleton.branches.count - 1;
    
    // Rotation is relative to the current parent, so set to identity
    // to maintain original orientation
    self.state.rotation = [CC3GLMatrix identity];
    
    // Move to the end of the branch
    self.state.parentPosition = 1.0f;
    
    // Move radius scale back to one, since the radius will now be relative to the new parent
    self.state.radiusScale = 1.0f;
}

/// <summary>
/// Moves backwards without drawing any branches.
/// </summary>
/// <param name="distance">Distance to move backwards.</param>
/// <remarks>
/// This follows the hiarchy of branches towards the root, so it may not
/// move in a straight line.
/// </remarks>
- (void)backwardWithDistance:(float)distance
{
    distance = distance * self.state.scale;
    while (self.state.parentIndex != -1 && distance > 0.0f) {
        float distanceOnBranch = self.state.parentPosition * [self.skeleton branchAtIndex:self.state.parentIndex].length;
        if (distance > distanceOnBranch) {
            self.state.parentIndex = [self.skeleton branchAtIndex:self.state.parentIndex].parentIndex;
            self.state.parentPosition = 1.0f;
            self.state.rotation = [CC3GLMatrix identity];
        } else {
            self.state.parentPosition -= distance / [self.skeleton branchAtIndex:self.state.parentIndex].length;
        }
        distance -= distanceOnBranch;
    }
    self.state.boneLevel = 99;
}

/// <summary>
/// Rotates the crayon around its local X-axis.
/// </summary>
- (void)pitchWithAngle:(float)angle
{
    GLKMatrix4 rotation = Matrix4MakeFromYawPitchRoll(0, angle, 0);
    CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrixFromGLMatrix:rotation.m];
    self.state.rotation = [self.state.rotation copyMultipliedBy:rotationMatrix];
}

/// <summary>
/// Scales the length of following branches.
/// </summary>
- (void)scaleBy:(float)scale
{
    self.state.scale = self.state.scale * scale;
}

/// <summary>
/// Scales the radius of following branches.
/// Note that radius is proportional to the radius at the parent's branch where the branch sprouts.
/// </summary>
/// <param name="scale"></param>
- (void)scaleRadiusBy:(float)scale
{
    self.state.radiusScale = self.state.radiusScale * scale;
}

/// <summary>
/// Rotates the crayon around its local Y-axis.
/// </summary>
- (void)twistByAngle:(float)angleInRadians
{
    GLKMatrix4 rotation = Matrix4MakeFromYawPitchRoll(angleInRadians, 0, 0);
    CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrixFromGLMatrix:rotation.m];
    self.state.rotation = [self.state.rotation copyMultipliedBy:rotationMatrix];
}

- (void)leafWithRotation:(float)rotation andSize:(CC3Vector2)size andColor:(CC3Vector4)color andAxisOffset:(float)axisOffset
{
    ccColor4F color4f;
    color4f.r = color.x;
    color4f.g = color.y;
    color4f.b = color.z;
    color4f.a = color.w;
    
    [self.skeleton addLeave:[[TreeLeaf alloc] initWithParentIndex:self.state.parentIndex
                                                         andColor:color4f
                                                      andRotation:rotation
                                                          andSize:size
                                                     andBoneIndex:self.state.parentBoneIndex
                                                    andAxisOffset:axisOffset]];
}

/// <summary>
/// Returns the radius of a given branch at the height.
/// </summary>
- (float)radiusAtParentIndex:(NSInteger)parentIndex andPosition:(float)position
{
    if (parentIndex == -1)
        return 128.0f;
    
    TreeBranch *branch = [self.skeleton branchAtIndex:parentIndex];
    
    return branch.startRadius + position * (branch.endRadius - branch.startRadius);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[TreeCrayon level=%d, depth=%lu]", self.level, (unsigned long)[self stackDepth]];
}

@end
