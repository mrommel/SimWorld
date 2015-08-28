//
//  Debug.m
//  SimWorld
//
//  Created by Michael Rommel on 27.08.15.
//  Copyright (c) 2015 Michael Rommel. All rights reserved.
//

#import "Debug.h"

int logIndentLevel = 0;

void MiRoLog_Indent()  { logIndentLevel++; }
void MiRoLog_Outdent() { if (logIndentLevel > 0) { logIndentLevel--; } }

void MiRoLog(NSString * format, ...)
{
#ifdef INTEND_LOGGING
    va_list args;
    va_start(args, format);
    
    NSString * indentString = [@"" stringByPaddingToLength:(2*logIndentLevel) withString:@" " startingAtIndex:0];
    
    NSLogv([NSString stringWithFormat:@"%@%@", indentString, format], args);
    
    va_end(args);
#endif // INTEND_LOGGING
}
