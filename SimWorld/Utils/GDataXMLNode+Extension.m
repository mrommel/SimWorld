//
//  GDataXMLNode+Extension.m
//  SimWorld
//
//  Created by Michael Rommel on 18.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "GDataXMLNode+Extension.h"

@implementation GDataXMLNode (Extension)

- (int)intValue
{
    return [[self stringValue] intValue];
}

- (int)intValueWithDefault:(int)defaultValue
{
    NSString *src = [self stringValue];
    if (src == nil) {
        return defaultValue;
    }
    return [src intValue];
}

#pragma mark -

- (float)floatValue
{
    return [[self stringValue] floatValue];
}

- (float)floatValueWithDefault:(float)defaultValue
{
    NSString *src = [self stringValue];
    if (src == nil) {
        return defaultValue;
    }
    return [src floatValue];
}

#pragma mark -

- (CC3Vector2)vector2Value
{
    NSString *src = [self stringValue];
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    return CC3Vector2Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue]);
}

- (CC3Vector2)vector2ValueWithDefault:(CC3Vector2)defaultValue
{
    NSString *src = [self stringValue];
    if (src == nil) {
        return defaultValue;
    }
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    return CC3Vector2Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue]);
}

#pragma mark -

- (CC3Vector)vector3Value
{
    NSString *src = [self stringValue];
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    return CC3VectorMake([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue]);
}

- (CC3Vector)vector3ValueWithDefault:(CC3Vector)defaultValue
{
    NSString *src = [self stringValue];
    if (src == nil) {
        return defaultValue;
    }
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    return CC3VectorMake([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue]);
}

#pragma mark -

- (CC3Vector4)vector4Value
{
    NSString *src = [self stringValue];
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    
    if (vectorComponents.count == 3) {
        return CC3Vector4Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue], 1.0f);
    } else if (vectorComponents.count == 4) {
        return CC3Vector4Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue], [[vectorComponents objectAtIndex:3] floatValue]);
    }
    
    return kCC3Vector4Zero;
}

- (CC3Vector4)vector4ValueWithDefault:(CC3Vector4)defaultValue
{
    NSString *src = [self stringValue];
    if (src == nil) {
        return defaultValue;
    }
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    
    if (vectorComponents.count == 3) {
        return CC3Vector4Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue], 1.0f);
    } else if (vectorComponents.count == 4) {
        return CC3Vector4Make([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue], [[vectorComponents objectAtIndex:3] floatValue]);
    }
    
    return kCC3Vector4Zero;
}

@end

@implementation GDataXMLElement (Extension)

- (int)intAttributeForName:(NSString *)name withDefault:(int)value
{
    GDataXMLNode * node = [self attributeForName:name];
    
    if (node) {
        return [node intValue];
    }
    
    return value;
}

- (float)floatAttributeForName:(NSString *)name withDefault:(float)value
{
    GDataXMLNode * node = [self attributeForName:name];
    
    if (node) {
        return [node floatValue];
    }
    
    return value;
}

- (NSString *)stringAttributeForName:(NSString *)name withDefault:(NSString *)value
{
    GDataXMLNode * node = [self attributeForName:name];
    
    if (node) {
        return [node stringValue];
    }
    
    return value;
}

@end
