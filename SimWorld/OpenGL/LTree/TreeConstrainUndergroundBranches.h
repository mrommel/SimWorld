//
//  TreeConstrainUndergroundBranches.h
//  SimWorld
//
//  Created by Michael Rommel on 31.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeContraints.h"

@interface TreeConstrainUndergroundBranches : TreeContraints

@property (atomic) float limit;

- (id)init;
- (id)initWithLimit:(float)limit;
- (BOOL)constrainForwardWithCrayon:(TreeCrayon *)crayon andDistance:(float *)distance andRadiusEndScale:(float *)radiusEndScale;

@end
