//
//  WindSource.h
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindSource : NSObject

/// @brief Returns the direction and strength of the wind, in a given position in the tree.
///
/// @param position Position local to the tree.
/// @returns Wind strength. 1 is a light wind, 10 is medium, 50 is strong, and 100 is hurricane.
- (CC3Vector)windStrengthForPosition:(CC3Vector)position;

- (void)update;

@end
