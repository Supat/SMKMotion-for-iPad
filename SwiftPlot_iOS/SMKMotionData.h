//
//  SMKMotionData.h
//  SMKMotion
//
//  Created by Supat Saetia on 10/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMKMotionData : NSObject

@property (readonly) NSData *rawData;
@property (readonly) NSMutableArray *quaternionData;
@property (readonly) NSMutableArray *gyroData;
@property (readonly) NSMutableArray *accelerometerData;
@property (readonly) NSData *intervalData;

@property (readonly) NSMutableArray *quaternionValues;
@property (readonly) NSMutableArray *gyroValues;
@property (readonly) NSMutableArray *accelerometerValues;
@property (readonly) uint16_t intervalValues;

@property (readonly) NSData *headerData;
@property (retain) NSData *quaternionEffectiveMask;
@property (retain) NSData *gyroEffectiveMask;
@property (retain) NSData *accelerometerEffectiveMask;
@property (retain) NSData *gyroSensitiveMask;
@property (retain) NSData *accelerometerSensitiveMask;

@property (readonly) BOOL quaternionEffective;
@property (readonly) BOOL gyroEffective;
@property (readonly) BOOL accelerometerEffective;

@property (readonly) float gyroSensitivity;
@property (readonly) float accelerometerSensitivity;

@property (readonly) NSString *stringValue;

@property (readonly) float quaternionW;
@property (readonly) float quaternionX;
@property (readonly) float quaternionY;
@property (readonly) float quaternionZ;
@property (readonly) float gyroX;
@property (readonly) float gyroY;
@property (readonly) float gyroZ;
@property (readonly) float accelerateX;
@property (readonly) float accelerateY;
@property (readonly) float accelerateZ;

@property (readonly) float roll;
@property (readonly) float pitch;
@property (readonly) float yaw;

- (id)initWithRawData:(NSData *)data;

@end
