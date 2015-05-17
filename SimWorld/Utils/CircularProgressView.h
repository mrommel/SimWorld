//
//  CircularProgressView.h
//  SimWorld
//
//  Created by Michael Rommel on 22.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularProgressView : UIView

@property (nonatomic) int percent;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.

- (id)initWithFrame:(CGRect)frame;
- (void)drawRect:(CGRect)rect;

- (void)setPercent:(int)percent;

@end
