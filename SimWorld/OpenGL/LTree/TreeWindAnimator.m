//
//  TreeWindAnimator.m
//  SimWorld
//
//  Created by Michael Rommel on 20.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "TreeWindAnimator.h"

#import "WindSource.h"

@interface TreeWindAnimator() {
    
}

@property (nonatomic, retain) WindSource *wind;

@end

@implementation TreeWindAnimator

- (id)initWithWind:(WindSource *)source
{
    self = [super init];
    
    if (self) {
        self.wind = source;
    }
    
    return self;
}



@end
