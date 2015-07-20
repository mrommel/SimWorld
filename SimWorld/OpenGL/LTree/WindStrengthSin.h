//
//  WindStrengthSin.h
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WindSource.h"

@interface WindStrengthSin : WindSource

- (CC3Vector)windStrengthForPosition:(CC3Vector)position;

@end
