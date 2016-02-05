//
//  SMKByteBuffer.m
//  SMKMotion
//
//  Created by Supat Saetia on 6/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "SMKByteBuffer.h"

@implementation SMKByteBuffer

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        m_buffer = [[NSMutableData alloc] init];
        beginingByte = [NSData dataWithBytes:"\x7E" length:1];
        endingByte = [NSData dataWithBytes:"\x7E" length:1];
        skipByte = [NSData dataWithBytes:"\x7D" length:1];
        maskByte = [NSData dataWithBytes:"\x20" length:1];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self scanBufferForMotionData];
        });
    }
    
    return self;
}

- (void)appendData:(NSData *)data
{
    [m_buffer appendData:data];
}

- (BOOL)verifyData:(NSMutableData *)data
{
    //NSLog(@"%@", data);
    if (data.length < 24) {
        return NO;
    } else {
        if (data.length > 24) {
            [data setLength:(NSUInteger)24];
        }
        NSData *checksum = [data subdataWithRange:NSMakeRange(23, 1)];
        NSData *body = [data subdataWithRange:NSMakeRange(0, 23)];
        
        NSData *sum = [NSData dataWithBytes:"\00" length:1];
        for (int i = 0; i < body.length; i++) {
            sum = [self XOR:sum with:[body subdataWithRange:NSMakeRange(i, 1)]];
        }
        //NSLog(@"%@ %@ %@ %@", data, body, checksum, sum);
        if ([sum isEqualToData:checksum]) {
            return YES;
        } else {
            return NO;
        }
    }
}

-(NSData *) XOR:(NSData *)data1 with:(NSData *)data2
{
    const char *bytes1 = [data1 bytes];
    const char *bytes2 = [data2 bytes];

    NSMutableData *result = [[NSMutableData alloc] init];
    for (int i = 0; i < data1.length; i++){
        const char xorByte = bytes1[i] ^ bytes2[i];
        [result appendBytes:&xorByte length:1];
    }
    return result;
}

- (void)scanBufferForMotionData
{
    NSLog(@"Start scan byte buffer");
    NSMutableData *motionData = [[NSMutableData alloc] init];
    NSData *buffer;
    NSData *nextBuffer;
    while (YES) {
        if (m_buffer.length > 10) {
            buffer = [m_buffer subdataWithRange:NSMakeRange(0, 1)];
            nextBuffer = [m_buffer subdataWithRange:NSMakeRange(1, 1)];
            //NSLog(@"%@:%@ %@", buffer, nextBuffer, motionData);
            if ([buffer isEqualToData:endingByte] && [nextBuffer isEqualToData:beginingByte]) {
                [m_buffer replaceBytesInRange:NSMakeRange(0, 2) withBytes:NULL length:0];
                NSError *error = nil;
                if ([self verifyData:motionData]) {
                    [[self delegate] SMKByteBufferDidDequeueMotionData:motionData error:error];
                } else {
                    error = [NSError errorWithDomain:@"Invalid data from remote sensor" code:(NSInteger)1 userInfo:nil];
                    NSLog(@"Invalid data %@", motionData);
                }
                motionData = nil;
                motionData = [[NSMutableData alloc] init];
            } else if ([buffer isEqualToData:beginingByte] || [buffer isEqualToData:endingByte]) {
                [m_buffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
            } else if ([buffer isEqualToData:skipByte]) {
                NSData *newByte = [self XOR:nextBuffer with:maskByte];
                [motionData appendData:newByte];
                [m_buffer replaceBytesInRange:NSMakeRange(0, 2) withBytes:NULL length:0];
            } else {
                [motionData appendData:buffer];
                [m_buffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
            }
            buffer = nil;
            nextBuffer = nil;
        }
    }
}

@end
