//
//  GameViewController.h
//  SimWorld
//
//  Created by Michael Rommel on 19.01.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GLViewController.h"
#import "HexagonMap.h"

@interface GameViewController : GLViewController {
    
}

@property (nonatomic, retain) HexagonMap *map;

@end
