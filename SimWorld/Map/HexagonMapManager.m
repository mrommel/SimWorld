//
//  HexagonMapManager.m
//  SimWorld
//
//  Created by Michael Rommel on 18.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "HexagonMapManager.h"

#import "HexagonMap.h"

@implementation HexagonMapManagerItem

- (id)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self) {
        self.name = name;
    }
    
    return self;
}

@end

@interface HexagonMapManager()

@end

@implementation HexagonMapManager

static HexagonMapManager *shared = nil;

+ (HexagonMapManager *)sharedInstance
{
    @synchronized (self) {
        if (shared == nil) {
            shared = [[self alloc] init];
        }
    }
    
    return shared;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)registerMap:(NSString *)mapName
{
    [self.items addObject:[[HexagonMapManagerItem alloc] initWithName:mapName]];
}

- (HexagonMapManagerItem *)itemForMapName:(NSString *)mapName
{
    for (HexagonMapManagerItem *item in self.items) {
        if ([item.name isEqualToString:mapName]) {
            return item;
        }
    }
    
    return nil;
}

- (UIImage *)thumbnailForMapName:(NSString *)mapName
{
    for (HexagonMapManagerItem *item in self.items) {
        if ([item.name isEqualToString:mapName]) {
            return item.image;
        }
    }
    
    return nil;
}

@end
