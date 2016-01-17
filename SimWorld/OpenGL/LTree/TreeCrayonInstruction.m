//
//  TreeCrayonInstruction.m
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeCrayonInstruction.h"

#import "TreeCrayon.h"
#import "CC3Math.h"
#import "CC3GLMatrix+Extension.h"
#import <GLKit/GLKit.h>
#import "TreeSkeleton.h"
#import "Debug.h"

@implementation TreeCrayonInstruction

- (void)executeCrayon:(TreeCrayon *)crayon
{
    // NOOP
}

@end

#pragma mark -

@implementation Bone

- (id)initWithDelta:(int)delta
{
    self = [super init];
    
    if (self) {
        self.delta = delta;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    [crayon executeBoneWithDelta:self.delta];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Bone delta=%d]", self.delta];
}

@end

#pragma mark -

@implementation Call

- (id)initWithName:(NSString *)name andProductions:(NSArray *)productions andDelta:(int)delta
{
    self = [super init];
    
    if (self) {
        NSAssert(self.delta <= 0, @"Delta must be negative or zero");
        
        self.name = name;
        self.delta = delta;
        self.productions = productions;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@ at level=%d", self, crayon.level);
    NSAssert(self.productions.count > 0, @"No productions exist for call.");
    
    if (crayon.level + self.delta < 0) {
        return;
    }
    
    crayon.level = crayon.level + self.delta;
    
    MiRoLog_Indent();
    NSUInteger i = RandomUIntBelow((unsigned int)self.productions.count);
    [[self.productions objectAtIndex:i] executeCrayon:crayon];
    MiRoLog_Outdent();
    
    crayon.level = crayon.level - self.delta;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Call name=%@, delta=%d, productions=%lu]", self.name, self.delta, (unsigned long)self.productions.count];
}

@end

#pragma mark -

@interface Child()

@property (nonatomic, retain) NSMutableArray *instructions;

@end

@implementation Child

- (id)init
{
    self = [super init];
    
    if (self) {
        self.instructions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addInstruction:(TreeCrayonInstruction *)instruction
{
    [self.instructions addObject:instruction];
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    
    MiRoLog_Indent();
    [crayon pushState];
    for (TreeCrayonInstruction *instruction in self.instructions) {
        [instruction executeCrayon:crayon];
    }
    [crayon popState];
    MiRoLog_Outdent();
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Child instructions=%lu]", (unsigned long)self.instructions.count];
}

@end

#pragma mark -

@interface Maybe()

@property (nonatomic, retain) NSMutableArray *instructions;

@end

@implementation Maybe

- (id)initWithChance:(float)chance
{
    self = [super init];
    
    if (self) {
        self.instructions = [[NSMutableArray alloc] init];
        self.chance = chance;
    }
    
    return self;
}

- (void)addInstruction:(TreeCrayonInstruction *)instruction
{
    [self.instructions addObject:instruction];
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    
    MiRoLog_Indent();
    if (RandomFloat() < self.chance) {
        for (TreeCrayonInstruction *instruction in self.instructions) {
            [instruction executeCrayon:crayon];
        }
    }
    MiRoLog_Outdent();
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Maybe chance=%.00f, instructions=%lu]", self.chance, (unsigned long)self.instructions.count];
}

@end

#pragma mark -

@interface Forward()

@property (atomic) float distance;
@property (atomic) float variation;
@property (atomic) float radius;

@end

@implementation Forward

- (id)initWithDistance:(float)distance andVariation:(float)variation andRadius:(float)radius
{
    self = [super init];
    
    if (self) {
        self.distance = distance;
        self.variation = variation;
        self.radius = radius;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    [crayon forwardWithDistance:(self.distance + self.variation * (RandomFloat() * 2.0f - 1.0f)) andRadius:self.radius];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Forward distance=%.00f, variation=%.00f, radius=%.00f]", self.distance, self.variation, self.radius];
}

@end

#pragma mark -

@interface Backward()

@property (atomic) float distance;
@property (atomic) float variation;

@end

@implementation Backward

- (id)initWithDistance:(float)distance andVariation:(float)variation
{
    self = [super init];
    
    if (self) {
        self.distance = distance;
        self.variation = variation;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    float randValue = self.distance + (RandomFloat() * 2.0 - 1.0) * self.variation;
    [crayon backwardWithDistance:randValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Backward distance=%.00f, variation=%.00f]", self.distance, self.variation];
}

@end

#pragma mark -

@interface Pitch()

@property (atomic) float angle;
@property (atomic) float variation;

@end

@implementation Pitch

- (id)initWithAngle:(float)angle andVariation:(float)variation
{
    self = [super init];
    
    if (self) {
        self.angle = GLKMathDegreesToRadians(angle);
        self.variation = GLKMathDegreesToRadians(variation);
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    float randValue = self.angle + (RandomFloat() * 2.0 - 1.0) * self.variation;
    [crayon pitchWithAngle:randValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Pitch angle=%.00f, variation=%.00f]", self.angle, self.variation];
}

@end

#pragma mark -

@interface Scale()

@property (atomic) float scale;
@property (atomic) float variation;

@end

@implementation Scale

- (id)initWithScale:(float)scale andVariation:(float)variation
{
    self = [super init];
    
    if (self) {
        self.scale = scale;
        self.variation = variation;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    float randValue = self.scale + (RandomFloat() * 2.0 - 1.0) * self.variation;
    [crayon scaleBy:randValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Scale scale=%.00f, variation=%.00f]", self.scale, self.variation];
}

@end

#pragma mark -

@interface ScaleRadius()

@property (atomic) float scale;
@property (atomic) float variation;

@end

@implementation ScaleRadius

- (id)initWithScale:(float)scale andVariation:(float)variation
{
    self = [super init];
    
    if (self) {
        self.scale = scale;
        self.variation = variation;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    float randValue = self.scale + (RandomFloat() * 2.0 - 1.0) * self.variation;
    [crayon scaleRadiusBy:randValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[ScaleRadius scale=%.00f, variation=%.00f]", self.scale, self.variation];
}

@end

#pragma mark -

@interface Twist()

@property (atomic) float angle;
@property (atomic) float variation;

@end

@implementation Twist

- (id)initWithAngle:(float)angle andVariation:(float)variation
{
    self = [super init];
    
    if (self) {
        self.angle = GLKMathDegreesToRadians(angle);
        self.variation = GLKMathDegreesToRadians(variation);
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    float randValue = self.angle + (RandomFloat() * 2.0 - 1.0) * self.variation;
    [crayon twistByAngle:randValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Twist angle=%.00f, variation=%.00f]", self.angle, self.variation];
}

@end

#pragma mark -

@interface Level()

@property (atomic) int deltaLevel;

@end

@implementation Level

- (id)initWithDelta:(int)deltaLevel
{
    self = [super init];
    
    if (self) {
        self.deltaLevel = deltaLevel;
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    crayon.level = crayon.level + self.deltaLevel;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Level deltaLevel=%d]", self.deltaLevel];
}

@end

#pragma mark -

@implementation Leaf

- (id)init
{
    self = [super init];
    
    if (self) {
        // NOOP
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@ at level=%d", self, crayon.level);
    if (crayon.level == 0)
    {
        float rotation = 0.0f;
        if (crayon.skeleton.leafAxis == nil) {
            rotation = RandomFloat() * M_PI * 2;
        }
        
        CC3Vector2 size = CC3Vector2Add(self.size, CC3Vector2ScaleUniform(self.sizeVariation, (2.0f * RandomFloat() - 1.0f)));
        CC3Vector4 color = CC3Vector4Add(self.color, CC3Vector4ScaleUniform(self.colorVariation, (2.0f * RandomFloat() - 1.0f)));
        [crayon leafWithRotation:rotation andSize:size andColor:color andAxisOffset:self.axisOffset];
    }
}

- (NSString *)description {
    return @"Leaf";
}

@end

#pragma mark -

@interface RequireLevel()

@property (nonatomic, retain) NSMutableArray *instructions;
@property (atomic) int level;
@property (nonatomic, retain) NSString *compareType;

@end

@implementation RequireLevel

- (id)initWithLevel:(int)level andCompareType:(NSString *)compareType
{
    self = [super init];
    
    if (self) {
        self.instructions = [[NSMutableArray alloc] init];
        self.level = level;
        
        if (compareType == nil) {
            self.compareType = kCompareTypeLess;
        } else {
            self.compareType = compareType;
        }
    }
    
    return self;
}

- (void)addInstruction:(TreeCrayonInstruction *)instruction
{
    [self.instructions addObject:instruction];
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    if ((crayon.level >= self.level && [self.compareType isEqualToString:kCompareTypeGreater]) || (crayon.level <= self.level && [self.compareType isEqualToString:kCompareTypeLess]))
    {
        for (TreeCrayonInstruction *instruction in self.instructions) {
            [instruction executeCrayon:crayon];
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[RequireLevel instructions=%lu, level=%d, compareType=%@]", (unsigned long)self.instructions.count, self.level, self.compareType];
}

@end

#pragma mark -

@implementation Align

- (id)init
{
    self = [super init];
    
    if (self) {
        // NOOP
    }
    
    return self;
}

- (void)executeCrayon:(TreeCrayon *)crayon
{
    MiRoLog(@"executeCrayon %@", self);
    CC3GLMatrix *transform = [crayon transform];
    
    CC3Vector branchDir = [transform extractUpDirection];
    CC3Vector axis = kCC3VectorUp;
    float dot = CC3VectorDot(axis, branchDir);
    
    // If branch is almost perpendicular to alignment axis,
    // just do nothing
    if (fabsf(dot) > 0.999f)
        return;
    
    // project axis onto the crayon's XZ plane
    CC3Vector axisXZ = CC3VectorAdd(axis, CC3VectorNegate(CC3VectorScaleUniform(branchDir, dot)));
    axisXZ = CC3VectorNormalize(axisXZ);
    
    float cosAngle = CC3VectorDot([transform extractBackwardDirection], axisXZ);
    
    // The dot product of two normalized vectors is always in range [-1,1],
    // but to account for rounding errors, we have to clamp it.
    // Otherwise, Acos will return NaN in some cases.
    cosAngle = CLAMP(cosAngle, -1, 1);
    
    // calculate the angle between the old Z-axis and axisXZ
    // this is also the twist angle required to align the crayon
    float rotation = acosf(cosAngle);
    
    // finally, perform the twist
    [crayon twistByAngle:rotation];
}

- (NSString *)description {
    return @"Align";
}

@end