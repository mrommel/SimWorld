//
//  TreeContraints.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeCrayon;

/// <summary>
/// Modifies the creation of branches on a tree, to make sure it meets certain requirements, such as
/// no branches sticking underground.
/// </summary>
@interface TreeContraints : NSObject

/// <summary>
/// Called whenever a branch is about to be created by the TreeCrayon.
/// This may alter the crayon prior the creation of the branch, or it may prohibit the creation
/// of the branch by returning false.
/// </summary>
/// <param name="crayon">The crayon about to create a branch.</param>
/// <param name="distance">The distance of the branch to be created. May be altered.</param>
/// <param name="radiusEndScale">Radius end scale of the branch to be created. May be altered.</param>
/// <returns>True if the branch may be created, false it if should be cancelled.</returns>
- (BOOL)constrainForwardWithCrayon:(TreeCrayon *)crayon andDistance:(float *)distance andRadiusEndScale:(float *)radiusEndScale;

@end
