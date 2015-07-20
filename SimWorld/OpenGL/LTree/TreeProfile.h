//
//  TreeProfile.h
//  SimWorld
//
//  Created by Michael Rommel on 16.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TreeGenerator;
@class SimpleTree;

@interface TreeProfile : NSObject

@property (nonatomic, retain) TreeGenerator *generator;
@property (atomic)  GLuint trunkTexture;
@property (atomic)  GLuint leafTexture;

- (id)initWithProfileName:(NSString *)profileName;
- (id)initWithTreeGenerator:(TreeGenerator *)generator andTrunkTexture:(GLuint)trunkTexture andLeafTexture:(GLuint)leafTexture;

- (SimpleTree *)generateSimpleTree;

@end
