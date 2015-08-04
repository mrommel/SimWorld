//
//  TreeCompositeConstraints.h
//  SimWorld
//
//  Created by Michael Rommel on 31.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TreeContraints.h"
#import "TreeCrayon.h"

@interface TreeCompositeConstraints : TreeContraints

@property (nonatomic, retain) NSMutableArray *constaints;
@property (nonatomic, retain) TreeContraints *userConstraint;

- (id)init;
- (BOOL)constrainForwardWithCrayon:(TreeCrayon *)crayon andDistance:(float *)distance andRadiusEndScale:(float *)radiusEndScale;

@end
