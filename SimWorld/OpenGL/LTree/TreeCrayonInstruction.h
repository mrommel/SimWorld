//
//  TreeCrayonInstruction.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

@class TreeCrayon;

@interface TreeCrayonInstruction : NSObject

- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Bone : TreeCrayonInstruction

@property (atomic) int delta;

- (id)initWithDelta:(int)delta;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Call : TreeCrayonInstruction

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *productions;
@property (atomic) int delta;

- (id)initWithName:(NSString *)name andProductions:(NSArray *)productions andDelta:(int)delta;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Child : TreeCrayonInstruction

- (id)init;
- (void)addInstruction:(TreeCrayonInstruction *)instruction;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Maybe : TreeCrayonInstruction

@property (atomic) float chance;

- (id)initWithChance:(float)chance;
- (void)addInstruction:(TreeCrayonInstruction *)instruction;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Forward : TreeCrayonInstruction

- (id)initWithDistance:(float)distance andVariation:(float)variation andRadius:(float)radius;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Backward : TreeCrayonInstruction

- (id)initWithDistance:(float)distance andVariation:(float)variation;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Pitch : TreeCrayonInstruction

- (id)initWithAngle:(float)distance andVariation:(float)variation;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Scale : TreeCrayonInstruction

- (id)initWithScale:(float)scale andVariation:(float)variation;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface ScaleRadius : TreeCrayonInstruction

- (id)initWithScale:(float)scale andVariation:(float)variation;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Twist : TreeCrayonInstruction

- (id)initWithAngle:(float)angle andVariation:(float)variation;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Level : TreeCrayonInstruction

- (id)initWithDelta:(int)delta;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Leaf : TreeCrayonInstruction

@property (atomic) CC3Vector4 color;
@property (atomic) CC3Vector4 colorVariation;

@property (atomic) CC3Vector2 size;
@property (atomic) CC3Vector2 sizeVariation;

@property (atomic) float axisOffset;

- (id)init;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

#define kCompareTypeLess @"less"
#define kCompareTypeGreater @"greater"

@interface RequireLevel : TreeCrayonInstruction

- (id)initWithLevel:(int)level andCompareType:(NSString *)compareType;
- (void)addInstruction:(TreeCrayonInstruction *)instruction;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end

@interface Align : TreeCrayonInstruction

- (id)init;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end