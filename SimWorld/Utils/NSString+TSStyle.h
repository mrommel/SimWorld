//
//  NSString+TSStyle.h
//  Telekom Service
//
//  Created by Jakob Sachse on 18.02.12.
//  Copyright (c) 2012 T-Systems International GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface NSString (TSStyle)

-(NSString*) limitFirstlineToMaxChars:(NSInteger)maxChars;
-(NSString*) limitToMaxChars:(NSInteger)maxChars;

+(NSString*) formatFileSize:(NSInteger)fileSize;
+(NSString*) formatTimeDistance:(NSInteger)seconds;
+(NSString*) formatTimeDistanceShort:(NSInteger) seconds postfix:(NSString*)postfix;

-(BOOL) contains:(NSString*)subString;
-(BOOL) containsString:(NSString *)string;
-(BOOL) containsString:(NSString *)string
               options:(NSStringCompareOptions) options;

-(NSString*) stringByRemovingCharactersInSet:(NSCharacterSet *)set;

- (NSString*)trim;
- (NSString*)trimWithCharacter:(char)character;
-(NSMutableString*) replaceString: (NSString*)pattern
                       withString: (NSString*)replacement;
-(int) indexOf:(NSString *)text;
-(BOOL) isEmpty;

@end

@interface NSString (isInteger)
-(BOOL)isInteger;
@end

@interface NSString (Backward)
-(CGSize)sizeWithMyFont:(UIFont*)fontToUse constrainedToSize:(CGSize)size;
-(CGSize)sizeWithMyFont:(UIFont *)fontToUse;
@end
