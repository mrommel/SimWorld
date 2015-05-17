//
//  UIConstants.h
//  SimWorld
//
//  Created by Michael Rommel on 07.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#ifndef SimWorld_UIConstants_h
#define SimWorld_UIConstants_h

#define SWLocalizedString(text) ([text isEqualToString:NSLocalizedString(text,nil)] ? [NSString stringWithFormat:@"##%@##", text] : NSLocalizedString(text,nil))

#define PRINT_RECT(text, frame) NSLog(@"%@: %d,%d -> %dx%d", text, (int)frame.origin.x, (int)frame.origin.y, (int)frame.size.width, (int)frame.size.height)

#define STATUSBAR_HEIGHT    ([UIApplication sharedApplication].statusBarFrame.size.height)
#define WINDOW_HEIGHT       ([[UIScreen mainScreen] bounds].size.height)
#define WINDOW_WIDTH        ([[UIScreen mainScreen] bounds].size.width)

#define BU      12
#define BU2     24

#define DEVICE_WIDTH    ([[UIScreen mainScreen] bounds].size.width)
#define DEVICE_HEIGHT    ([[UIScreen mainScreen] bounds].size.height)

#endif
