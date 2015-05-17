//
//  ByteReader.m
//  SimWorld
//
//  Created by Michael Rommel on 30.11.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "ByteReader.h"

@interface ByteReader() {
    
}

@property (nonatomic, assign)   NSData      *data;
@property (atomic, assign)      int         index;

@end

@implementation ByteReader

- (id)initWithData:(NSData *)data
{
    self = [super init];
    
    if (self) {
        self.data = data;
        self.index = 0;
    }
    
    return self;
}

- (char)readByte
{
    char oneByte[1];
    [self.data getBytes:oneByte range:NSMakeRange(self.index, 1)];
    self.index += 1;
    
    return oneByte[0];
}

- (int)readInt
{
    char fourBytes[4];
    [self.data getBytes:fourBytes range:NSMakeRange(self.index, 4)];
    int value = *(int*)(fourBytes);
    self.index += 4;
    
    return value;
}

- (NSString *)readString
{
    NSMutableString *string = [[NSMutableString alloc] init];
    char val;
 
    while ((val = [self readByte]) != 0x00) {
        [string appendString:[NSString stringWithFormat:@"%c", val]];
    }
    
    return string;
}

- (NSString *)readStringWithLength:(int)length
{
    if (length <= 0) {
        return @"";
    }

    NSMutableString *string = [[NSMutableString alloc] init];
    char val;
    int i = length;
    
    while (i-- > 0) {
        val = [self readByte];
        [string appendString:[NSString stringWithFormat:@"%c", val]];
    }
    self.index += length;
    
    return string;
}

- (NSArray *)readStringArrayFromLength:(int)length
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSData *subData = [self.data subdataWithRange:NSMakeRange(self.index, length)];
    self.index += length;
    
    ByteReader *innerReader = [[ByteReader alloc] initWithData:subData];
    
    int sum = length;
    while (sum > 0) {
        NSString *tmp = [innerReader readString];
        sum -= [tmp length];
        sum -= 1;
        [array addObject:tmp];
    }
    
    /*char val;
    
    while ((val = [self readByte]) != 0x00) {
        [string appendString:[NSString stringWithFormat:@"%c", val]];
    }*/
    
    return array;
}

@end
