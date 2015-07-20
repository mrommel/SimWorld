//
//  WindStrengthSin.m
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "WindStrengthSin.h"

#import "CC3GLMatrix+Extension.h"

@interface WindStrengthSin() {
    int _time;
}

@end

@implementation WindStrengthSin

- (CC3Vector)windStrengthForPosition:(CC3Vector)position
{
    float seconds = _time / 1000.0f;
    CC3Vector windStrength = CC3VectorScaleUniform(CC3VectorScaleUniform(kCC3VectorRight, 10.0f), sinf(seconds * 3));
    windStrength = CC3VectorAdd(windStrength, CC3VectorScaleUniform(CC3VectorScaleUniform(kCC3VectorBackward, 15.0f), sinf(seconds * 5 + 1)));
    windStrength = CC3VectorAdd(windStrength, CC3VectorScaleUniform(CC3VectorScaleUniform(kCC3VectorBackward, 1.5f), sinf(seconds * 11 + 3)));
    windStrength = CC3VectorAdd(windStrength, CC3VectorScaleUniform(CC3VectorScaleUniform(kCC3VectorRight, 1.5f), sinf(seconds * 11 + 3) * sinf(seconds * 1 + 3)));
    return windStrength;
}

- (void)update
{
    _time++;
}

@end
