//
//  NSDictionary+Extensions.m
//  DSL Hilfe
//
//  Created by Jakob Sachse on 24.01.13.
//
//

#import "NSDictionary+Extensions.h"

#import "NSString+TSStyle.h"

@implementation NSDictionary (Extensions)

- (id)valueForKeyContaining:(NSString *)partialKey
{
    if(!partialKey){
        return nil;
    }
    
    if([partialKey isEqualToString:@""]){
        return nil;
    }
    
    for (NSString* key in self) {
        NSRange range = [key rangeOfString:partialKey];
        if (range.location != NSNotFound) {
            return [self valueForKey: key];
        }
    }
    
    return nil;
}

- (id)objectForKeyContaining:(NSString *)partialKey
{
    if (!partialKey) {
        return nil;
    }
    
    if ([partialKey isEqualToString:@""]) {
        return nil;
    }
    
    for (NSString* key in self) {
        NSRange range = [key rangeOfString:partialKey];
        if (range.location != NSNotFound){
            return [self objectForKey:key];
        }
    }
    
    return nil;
}

- (id)getValueForKeyPath:(NSString *)path
{
    return [self getValueForKeyPath:path withDefaultValue:nil];
}

- (id)getValueForKeyPath:(NSString *)path withDefaultValue:(id)defaultValue
{
    if (!path) {
        return defaultValue;
    }
    
    if ([path isEqualToString:@""]) {
        return defaultValue;
    }
    
    if ([self objectForKeyContaining: path]) {
        
        id val = [self valueForKeyContaining:path];
        
        // return the value
        if([val isKindOfClass: [NSDictionary class]]) {
            return [[val valueForKey: @"text"] trim];
        }
        
        if([val isKindOfClass: [NSString class]]) {
            return [val trim];
        }
    }
    
    NSDictionary *tmp = self;
    
    for (NSString *key in [path componentsSeparatedByString:@"/"]) {
        // check if current key is the last
        if ([path hasSuffix: [NSString stringWithFormat:@"/%@", key]]) {
            
            id val = [tmp valueForKeyContaining: key];
            
            // return the value
            if ([val isKindOfClass:[NSDictionary class]]) {
                return [[val valueForKey: @"text"] trim];
            }
            
            if ([val isKindOfClass:[NSString class]]) {
                return [val trim];
            }
            
            if ([val isKindOfClass:[NSArray class]]) {
                return val;
            }
            
            //NSLog(@"Unknown type: %@", [val class]);
            return val;
        } else {
            // go deep into dict
            tmp = [tmp objectForKeyContaining: key];
        }
    }
    
    return defaultValue;
}

- (NSArray*)getArrayForKeyPath:(NSString *)path
{
    return [self getValueForKeyPath: path withDefaultValue: nil];
}

-(int)getIntValueForKeyPath:(NSString *)path withDefaultValue: (int)defaultValue
{
    NSString *val = [self getValueForKeyPath: path withDefaultValue: [NSString stringWithFormat: @"%d", defaultValue]];
    
    if(val == nil)
        return defaultValue;
    
    return [val intValue];
}

-(id)getObjectForKeyPath:(NSString *)path withDefaultValue:(id)defaultValue
{
    if (!path) {
        return defaultValue;
    }
    
    if ([path isEqualToString:@""]) {
        return defaultValue;
    }
    
    if ([self objectForKeyContaining:path]) {
        
        id val = [self valueForKeyContaining: path];
        
        return val;
    }
    
    NSDictionary *tmp = self;
    
    for (NSString *key in [path componentsSeparatedByString: @"/"]) {
        
        // check the key exists
        /*if(![tmp containsKey: key])
         return defaultValue;*/
        
        // check if current key is the last
        if ([path hasSuffix: [NSString stringWithFormat: @"/%@", key]]) {
            
            id val = [tmp valueForKeyContaining: key];
            
            // return the value
            return val;
        } else {
            // go deep into dict
            tmp = [tmp objectForKeyContaining: key];
        }
    }
    
    return defaultValue;
}

// experimental
-(void)setTheValue: (id)obj forKeyPath: (NSString*)path {
    
    if(![path contains: @"/"]) {
        [self setValue: obj forKey: path];
        return;
    }
    
    NSMutableDictionary *tmp = (NSMutableDictionary*)self;
    NSArray *keys = [path componentsSeparatedByString: @"/"];
    for(int i = 0; i < [keys count]; ++i) {
        
        NSString *key = [[keys objectAtIndex: i] copy];
        
        NSLog(@"add key: %@", key);
        
        // last entry
        if(i == [keys count] - 1) {
            // store it
            [tmp setObject: obj forKey: key];
        } else {
            if([tmp containsKey: key]) {
                tmp = [tmp objectForKeyContaining: key];
                
                if(![tmp isKindOfClass: [NSDictionary class]]) {
                    /*id v = [tmp copy];
                    
                    NSDictionary *dict = [[NSDictionary alloc] init];
                    
                    [tmp setValue: v forKey: key];*/
                    NSLog(@"something bad happend");
                }
            } else {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                
                [tmp setObject: dict forKey: key];
                tmp = [tmp objectForKeyContaining: key];
            }
        }
        
        //NSLog(@"dict: %@", [self description]);
    }
}

-(BOOL)containsKey: (NSString*)key {
    return [self objectForKey: key] != nil;
}

- (NSDictionary *)dictForKey:(NSString *)key
{
    return [self objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [self objectForKey:key];
}

- (int)intForKey:(NSString *)key
{
    return [[self objectForKey:key] intValue];
}

- (CC3Vector)vector3ForKey:(NSString *)key
{
    NSString *src = [self stringForKey:key];
    NSArray *vectorComponents = [src componentsSeparatedByString:@","];
    return CC3VectorMake([[vectorComponents objectAtIndex:0] floatValue], [[vectorComponents objectAtIndex:1] floatValue], [[vectorComponents objectAtIndex:2] floatValue]);
}

@end
