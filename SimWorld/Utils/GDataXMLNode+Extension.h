//
//  GDataXMLNode+Extension.h
//  SimWorld
//
//  Created by Michael Rommel on 18.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDataXMLNode.h"
#import "CC3GLMatrix+Extension.h"

@interface GDataXMLNode (Extension)

- (int)intValue;
- (int)intValueWithDefault:(int)defaultValue;

- (float)floatValue;
- (float)floatValueWithDefault:(float)defaultValue;

- (CC3Vector2)vector2Value;
- (CC3Vector2)vector2ValueWithDefault:(CC3Vector2)defaultValue;

- (CC3Vector)vector3Value;
- (CC3Vector)vector3ValueWithDefault:(CC3Vector)defaultValue;

- (CC3Vector4)vector4Value;
- (CC3Vector4)vector4ValueWithDefault:(CC3Vector4)defaultValue;

@end

@interface GDataXMLElement (Extension)

- (int)intAttributeForName:(NSString *)name withDefault:(int)value;
- (float)floatAttributeForName:(NSString *)name withDefault:(float)value;
- (NSString *)stringAttributeForName:(NSString *)name withDefault:(NSString *)value;

@end
