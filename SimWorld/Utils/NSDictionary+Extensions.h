//
//  NSDictionary+Extensions.h
//  DSL Hilfe
//
//  Created by Jakob Sachse on 24.01.13.
//
//

#import <Foundation/Foundation.h>

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

- (CC3Vector)vector3ForKey:(NSString *)key;

-(id)getValueForKeyPath:(NSString *)path withDefaultValue: (id)defaultValue;
-(int)getIntValueForKeyPath:(NSString *)path withDefaultValue: (int)defaultValue;
-(id)getObjectForKeyPath:(NSString *)path withDefaultValue: (id)defaultValue;
-(NSArray *)getArrayForKeyPath:(NSString *)path;

-(void)setTheValue: (id)obj forKeyPath: (NSString*)path;

@end
