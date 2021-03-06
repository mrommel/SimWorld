//
//  NSDictionary+Extensions.h
//  DSL Hilfe
//
//  Created by Jakob Sachse on 24.01.13.
//
//

#import <Foundation/Foundation.h>

#import "CC3GLMatrix+Extension.h"

@interface NSDictionary (Extensions)

-(BOOL)containsKey: (NSString*)key;

-(id)valueForKeyContaining:(NSString *)key;

/**
 * path must be something like this: key/to/entry 
 *
 */
-(id)getValueForKeyPath:(NSString *)path;

- (NSDictionary *)dictForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

- (int)intForKey:(NSString *)key;
- (int)intForKey:(NSString *)key withDefault:(int)value;

- (float)floatForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key withDefault:(float)value;

- (CC3Vector)vector3ForKey:(NSString *)key;
- (CC3Vector)vector3ForKey:(NSString *)key withDefault:(CC3Vector)value;

- (CC3Vector4)vector4ForKey:(NSString *)key;
- (CC3Vector4)vector4ForKey:(NSString *)key withDefault:(CC3Vector4)value;

- (CC3Vector2)vector2ForKey:(NSString *)key;
- (CC3Vector2)vector2ForKey:(NSString *)key withDefault:(CC3Vector2)value;

-(id)getValueForKeyPath:(NSString *)path withDefaultValue: (id)defaultValue;
-(int)getIntValueForKeyPath:(NSString *)path withDefaultValue: (int)defaultValue;
-(id)getObjectForKeyPath:(NSString *)path withDefaultValue: (id)defaultValue;
-(NSArray *)getArrayForKeyPath:(NSString *)path;

-(void)setTheValue: (id)obj forKeyPath: (NSString*)path;

@end
