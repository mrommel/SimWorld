//
//  CircularProgressView.m
//  SimWorld
//
//  Created by Michael Rommel on 22.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "CircularProgressView.h"

@interface CircularProgressView () {
    CGFloat startAngle;
    CGFloat endAngle;
}

@end

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
    }
    
    return self;
}

- (void)setPercent:(int)percent
{
    _percent = percent;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    NSString* textContent = [NSString stringWithFormat:@"%d", self.percent];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:130
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (self.percent / 100.0) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 20;
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    
    // Text Drawing
    CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71/2.0, (rect.size.height / 2.0) - 45/2.0, 71, 45);
    [[UIColor blackColor] setFill];

    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping; /// Set line break mode
    paragraphStyle.alignment = NSTextAlignmentCenter; /// Set text alignment
    NSDictionary *attributes = @{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:42.5],
                                  NSParagraphStyleAttributeName:paragraphStyle };
    
    [textContent drawInRect:textRect withAttributes:attributes];
}

@end
