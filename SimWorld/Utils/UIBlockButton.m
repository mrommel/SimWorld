//
//  UIBlockButton.m
//  SimWorld
//
//  Created by Michael Rommel on 08.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "UIBlockButton.h"

@implementation UIBlockButton

-(void) handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock) action
{
    _actionBlock = action;
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

-(void) callActionBlock:(id)sender{
    _actionBlock();
}

@end
