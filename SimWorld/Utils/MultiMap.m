//
//  MultiMap.m
//  SimWorld
//
//  Created by Michael Rommel on 19.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "MultiMap.h"

@interface MultiMap() {
    NSMutableDictionary *_dict;
}

@end

@implementation MultiMap

+ (MultiMap *)map
{
    return [[MultiMap alloc] init];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addObject:(id)object forKey:(NSString *)key
{
    NSMutableArray *tmp = [_dict objectForKey:key];
    if (tmp) {
        [tmp addObject:object];
    } else {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:object];
        [_dict setObject:array forKey:key];
    }
}

- (NSMutableArray *)objectsForKey:(NSString *)key
{
    NSMutableArray *tmp = [_dict objectForKey:key];
    if (tmp) {
        return tmp;
    } else {
        return [[NSMutableArray alloc] init];
    }
}

- (NSMutableArray *)getAllValues
{
    NSMutableArray *values = [NSMutableArray array];
    
    for (id key in _dict) {
        NSMutableArray *value = [_dict objectForKey:key];
        for (id obj in value) {
            [values addObject:obj];
        }
    }
    
    return values;
}

@end
