//
//  UIBlockButton.h
//  SimWorld
//
//  Created by Michael Rommel on 08.12.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ActionBlock)();

@interface UIBlockButton : UIButton {
    ActionBlock _actionBlock;
}

-(void) handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock) action;

@end
