//
//  Debug.h
//  SimWorld
//
//  Created by Michael Rommel on 27.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

void MiRoLog_Indent();
void MiRoLog_Outdent();
void MiRoLog(NSString *format, ...);

/** Returns a string description of the specified BOOL in the form "YES" / "NO" */
NSString* NSStringFromBOOL(BOOL value);
