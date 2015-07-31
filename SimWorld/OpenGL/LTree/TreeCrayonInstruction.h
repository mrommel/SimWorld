//
//  TreeCrayonInstruction.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property (nonatomic, retain)NSArray *productions;
@property (atomic) int delta;

- (id)initWithProductions:(NSArray *)productions andDelta:(int)delta;
- (void)executeCrayon:(TreeCrayon *)crayon;

@end
