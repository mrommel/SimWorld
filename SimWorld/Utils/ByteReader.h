//
//  ByteReader.h
//  SimWorld
//
//  Created by Michael Rommel on 30.11.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ByteReader : NSObject

- (id)initWithData:(NSData *)data;

- (char)readByte;
- (int)readInt;
- (NSString *)readString;
- (NSString *)readStringWithLength:(int)length;
- (NSArray *)readStringArrayFromLength:(int)length;

@end
