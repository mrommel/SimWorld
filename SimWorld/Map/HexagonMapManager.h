//
//  HexagonMapManager.h
//  SimWorld
//
//  Created by Michael Rommel on 18.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef void (^CompleteBlock)();

@interface HexagonMapManagerItem : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) UIImage *image;

- (id)initWithName:(NSString *)name;

@end

@interface HexagonMapManager : NSObject

@property (nonatomic,retain) NSMutableArray *items;

+ (HexagonMapManager *)sharedInstance;

- (void)registerMap:(NSString *)mapName;

- (UIImage *)thumbnailForMapName:(NSString *)mapName;
- (HexagonMapManagerItem *)itemForMapName:(NSString *)mapName;

@end
