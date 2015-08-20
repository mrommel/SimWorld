//
//  MultiMap.h
//  SimWorld
//
//  Created by Michael Rommel on 19.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiMap : NSObject

+ (MultiMap *)map;

- (id)init;

- (void)addObject:(id)object forKey:(NSString *)key;
- (NSMutableArray *)objectsForKey:(NSString *)key;

@property (readonly, getter=getAllValues) NSMutableArray *allValues;

@end
