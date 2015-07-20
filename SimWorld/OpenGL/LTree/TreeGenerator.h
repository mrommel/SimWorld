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

- (id)initFromTreeFile:(NSString *)ltreeFilename;

- (TreeSkeleton *)generateTree;

@end
