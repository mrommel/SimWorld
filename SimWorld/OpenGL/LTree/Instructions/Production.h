//
//  Production.h
//  SimWorld
//
//  Created by Michael Rommel on 21.07.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TreeCrayon.h"

@interface Production : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *instructions; // TreeCrayonInstruction

- (id)initWithName:(NSString *)name;

- (void)executeCrayon:(TreeCrayon *)crayon;

@end
