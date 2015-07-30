//
//  TreeGenerator.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeSkeleton;

@interface TreeGenerator : NSObject

@property (nonatomic, retain) NSString *rootName;
@property (atomic) CC3Vector leafAxis;
@property (atomic) int maxLevel;
@property (atomic) int boneLevels;

- (id)initFromTreeFile:(NSString *)ltreeFilename;

- (TreeSkeleton *)generateTree;

@end
