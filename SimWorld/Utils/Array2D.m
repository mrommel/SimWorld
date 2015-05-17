/*
 * Array2D, simple NSMutableArray like collection but two dimensional
 * Objects at positions are mutable, size is immutable.
 *
 * Copyright (c) 2010 <mattias.wadman@gmail.com>
 *
 * MIT License:
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "Array2D.h"

#import <UIKit/UIKit.h>

#import "HexPoint.h"

// forward declaration
@class Array2D;

@interface Array2DEnumerator : NSEnumerator

+ (Array2DEnumerator *)withArray2D:(Array2D *)anArray;
- (Array2DEnumerator *)initWithArray2D:(Array2D *)anArray;

@property (nonatomic, retain) Array2D *array;
@property (nonatomic, assign) NSUInteger position;

@end

@implementation Array2DEnumerator

@synthesize array;
@synthesize position;

+ (Array2DEnumerator *)withArray2D:(Array2D *)anArray {
    return [[[Array2DEnumerator alloc] initWithArray2D:anArray] autorelease];
}

- (Array2DEnumerator *)initWithArray2D:(Array2D *)anArray {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    self.array = anArray;
    self.position = 0;
    
    return self;
}

- (NSArray *)allObjects {
    NSMutableArray *objects = [NSMutableArray array];
    
    id o;
    while ((o = [self nextObject])) {
        [objects addObject:o];
    }
    
    return objects;
}

- (NSValue *)nextObject {
    CGPoint pos = CGPointMake(self.position % (NSUInteger)self.array.size.width,
                              self.position / (NSUInteger)self.array.size.height);
    if (pos.y >= self.array.size.height) {
        return nil;
    }
    
    self.position++;
    
    return [NSValue valueWithCGPoint:pos];;
}

- (void)dealloc {
    self.array = nil;
    
    [super dealloc];
}

@end


@interface Array2D ()

@property(assign) id *objects;

@end


@implementation Array2D

@synthesize size;
@synthesize objects;

+ (id)arrayWithSize:(CGSize)aSize {
    return [[[Array2D alloc] initWithSize:aSize] autorelease];
}

- (id)initWithSize:(CGSize)aSize {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    self->size = aSize;
    self.objects = calloc((int)aSize.width * (int)aSize.height,
                          sizeof(self.objects[0]));
    
    return self;
}

- (void)dealloc {
    int n = (int)self.size.width * (int)self.size.height;
    
    for (int i = 0; i < n; i++) {
        if (self.objects[i] == nil) {
            continue;
        }
        
        [self.objects[i] release];
    }
    
    free(self.objects);
    
    [super dealloc];
}

- (NSEnumerator *)positionEnumerator {
    return [Array2DEnumerator withArray2D:self];
}

- (BOOL)insideX:(int)x andY:(int)y
{
    return x >= 0 && x < (int)self.size.width && y >= 0 && y < (int)self.size.height;
}

- (void)insideOrException:(int)x y:(int)y
{
    if (![self insideX:x andY:y]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"(%d,%d) is outside array with size (%dx%d)", x, y, (int)self.size.width, (int)self.size.height];
    }
}

- (id)objectAtX:(int)x andY:(int)y
{
    [self insideOrException:x y:y];
    return self.objects[y * (int)self.size.width + x];
}

- (id)objectAt:(CGPoint)pos
{
    return [self objectAtX:(int)pos.x andY:(int)pos.y];
}

- (void)setObject:(id)object atX:(int)x andY:(int)y
{
    [self insideOrException:x y:y];
    
    int i = y * (int)self.size.width + x;
    [self.objects[i] release];
    self.objects[i] = [object retain];
}

- (void)setObject:(id)object at:(CGPoint)pos {
    [self setObject:object atX:(int)pos.x andY:(int)pos.y];
}

#pragma mark -
#pragma mark float functions

- (void)smoothenFloat
{
    for (int i = 1; i < self.size.width - 1; ++i) {
        for (int j = 1; j < self.size.height - 1; ++j) {
            float total = 0.0f;
            for (int u = -1; u <= 1; u++) {
                for (int v = -1; v <= 1; v++) {
                    total += [[self objectAtX:i + u andY:j + v] floatValue];
                }
            }
            
            [self setObject:[[NSNumber alloc] initWithFloat:total / 9.0f] atX:i andY:j];
        }
    }
}

- (void)fillWithFloat:(float)value
{
    for (int i = 0; i < self.size.width; ++i) {
        for (int j = 0; j < self.size.height; ++j) {
            [self setObject:[[NSNumber alloc] initWithFloat:value] atX:i andY:j];
        }
    }
}

- (float)floatAtX:(int)x andY:(int)y
{
    return [[self objectAtX:x andY:y] floatValue];
}

- (void)setFloat:(float)object atX:(int)x andY:(int)y
{
    [self setObject:[[NSNumber alloc] initWithFloat:object] atX:x andY:y];
}

- (float)maximumFloatOnHexAtX:(int)x andY:(int)y withDefault:(float)def
{
    float maximum = def;
    
    HexPoint *point = [[HexPoint alloc] initWithX:x andY:y];
    
    for (id obj in HEXDIRECTIONS) {
        HexDirection dir = [obj intValue];
        HexPoint *neighbor = [point neighborIn:dir];
        if ([self insideX:neighbor.x andY:neighbor.y]) {
            float current = [self floatAtX:neighbor.x andY:neighbor.y];
            maximum = MAX(maximum, current);
        }
    }
    
    return maximum;
}

#pragma mark -
#pragma mark int functions

- (void)smoothenInt
{
    for (int i = 1; i < self.size.width - 1; ++i) {
        for (int j = 1; j < self.size.height - 1; ++j) {
            float total = 0.0f;
            for (int u = -1; u <= 1; u++) {
                for (int v = -1; v <= 1; v++) {
                    total += [[self objectAtX:i + u andY:j + v] floatValue];
                }
            }
            
            [self setObject:[[NSNumber alloc] initWithFloat:total / 9.0f] atX:i andY:j];
        }
    }
}

- (void)fillWithInt:(int)value
{
    for (int i = 0; i < self.size.width; ++i) {
        for (int j = 0; j < self.size.height; ++j) {
            [self setObject:[[NSNumber alloc] initWithInt:value] atX:i andY:j];
        }
    }
}

- (int)intAtX:(int)x andY:(int)y
{
    return [[self objectAtX:x andY:y] intValue];
}

- (void)setInt:(int)object atX:(int)x andY:(int)y
{
    [self setObject:[[NSNumber alloc] initWithInt:object] atX:x andY:y];
}

- (int)maximumIntOnHexAtX:(int)x andY:(int)y withDefault:(int)def
{
    int maximum = def;
    
    HexPoint *point = [[HexPoint alloc] initWithX:x andY:y];
    
    for (id obj in HEXDIRECTIONS) {
        HexDirection dir = [obj intValue];
        HexPoint *neighbor = [point neighborIn:dir];
        if ([self insideX:neighbor.x andY:neighbor.y]) {
            float current = [self floatAtX:neighbor.x andY:neighbor.y];
            maximum = MAX(maximum, current);
        }
    }
    
    return maximum;
}

@end