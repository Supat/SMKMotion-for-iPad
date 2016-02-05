//
//  SMKByteBuffer.h
//  SMKMotion
//
//  Created by Supat Saetia on 6/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMKMotionData.h"

@class SMKByteBuffer;
@protocol SMKByteBufferDelegate <NSObject>
- (void)SMKByteBufferDidDequeueMotionData:(NSMutableData *)data error:(NSError *)error;

@end

@interface SMKByteBuffer : NSObject
{
    @private
    NSMutableData *m_buffer;
    NSData *beginingByte;
    NSData *endingByte;
    NSData *skipByte;
    NSData *maskByte;
}

@property (retain) id delegate;

- (void)appendData:(NSData *)data;

@end
