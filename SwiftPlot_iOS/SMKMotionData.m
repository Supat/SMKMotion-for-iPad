//
//  SMKMotionData.m
//  SMKMotion
//
//  Created by Supat Saetia on 10/10/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "SMKMotionData.h"

@implementation SMKMotionData

@synthesize rawData;
@synthesize quaternionData;
@synthesize quaternionValues;
@synthesize gyroData;
@synthesize gyroValues;
@synthesize accelerometerData;
@synthesize accelerometerValues;
@synthesize intervalData;
@synthesize intervalValues;
@synthesize headerData;

@synthesize quaternionEffective;
@synthesize gyroEffective;
@synthesize accelerometerEffective;

@synthesize gyroSensitivity;
@synthesize accelerometerSensitivity;

@synthesize quaternionEffectiveMask;
@synthesize gyroEffectiveMask;
@synthesize accelerometerEffectiveMask;
@synthesize gyroSensitiveMask;
@synthesize accelerometerSensitiveMask;

@synthesize quaternionW;
@synthesize quaternionX;
@synthesize quaternionY;
@synthesize quaternionZ;
@synthesize gyroX;
@synthesize gyroY;
@synthesize gyroZ;
@synthesize accelerateX;
@synthesize accelerateY;
@synthesize accelerateZ;

@synthesize roll;
@synthesize pitch;
@synthesize yaw;

- (id)init
{
    self = [super init];
    if (self) {
        rawData = [[NSData alloc] init];
        quaternionData = [[NSMutableArray alloc] init];
        gyroData = [[NSMutableArray alloc] init];
        accelerometerData = [[NSMutableArray alloc] init];
        intervalData = [[NSData alloc] init];
        
        headerData = [[NSData alloc] init];
        
        quaternionValues = [[NSMutableArray alloc] init];
        gyroValues = [[NSMutableArray alloc] init];
        accelerometerValues = [[NSMutableArray alloc] init];
        intervalValues = 0;
        
        quaternionEffective = NO;
        gyroEffective = NO;
        accelerometerEffective = NO;
    }
    
    return self;
}

- (id)initWithRawData:(NSData *)data
{
    self = [super init];
    if (self) {
        rawData = data;

        headerData = [self extractHeaderData];
        
        accelerometerData = [self extractAccelerometerData];
        intervalData = [self extractIntervalData];
        
        /*
        NSLog(@"%@ %@ [%@ %@ %@ %@] [%@ %@ %@] [%@ %@ %@] %@", rawData, headerData,
              quaternionData[0],
              quaternionData[1],
              quaternionData[2],
              quaternionData[3],
              gyroData[0],
              gyroData[1],
              gyroData[2],
              accelerometerData[0],
              accelerometerData[1],
              accelerometerData[2],
              intervalData);
        */
        
        quaternionEffective = NO;
        gyroEffective = NO;
        accelerometerEffective = NO;
        
        quaternionEffectiveMask = [NSData dataWithBytes:"\x40" length:1];
        gyroEffectiveMask = [NSData dataWithBytes:"\x20" length:1];
        accelerometerEffectiveMask = [NSData dataWithBytes:"\x10" length:1];
        gyroSensitiveMask = [NSData dataWithBytes:"\x0C" length:1];
        accelerometerSensitiveMask = [NSData dataWithBytes:"\x03" length:1];
         
        [self setupSensorParameterFromHeader];
         
        if (quaternionEffective) {
            quaternionData = [self extractQuaternionData];
            quaternionValues = [self decodeQuaternionFromRaw];
        } else {
            quaternionData = [[NSMutableArray alloc] init];
            quaternionValues = [[NSMutableArray alloc] init];
        }
        if (gyroEffective) {
            gyroData = [self extractGyroData];
            gyroValues = [self decodeGyroFromRaw];
        } else {
            gyroData = [[NSMutableArray alloc] init];
            gyroValues = [[NSMutableArray alloc] init];
        }
        if (accelerometerEffective) {
            accelerometerData = [self extractAccelerometerData];
            accelerometerValues = [self decodeAccelerometerFromRaw];
            [self calculateRotationalMatrix];
        } else {
            accelerometerData = [[NSMutableArray alloc] init];
            accelerometerValues = [[NSMutableArray alloc] init];
        }
        intervalValues = [self decodeIntervalFromRaw];
        
        /*
        NSLog(@"[%f %f %f %f] [%f %f %f] [%f %f %f] %d",
              [quaternionValues[0] floatValue],
              [quaternionValues[1] floatValue],
              [quaternionValues[2] floatValue],
              [quaternionValues[3] floatValue],
              [gyroValues[0] floatValue],
              [gyroValues[1] floatValue],
              [gyroValues[2] floatValue],
              [accelerometerValues[0] floatValue],
              [accelerometerValues[1] floatValue],
              [accelerometerValues[2] floatValue],
              intervalValues);
         */
        
        //NSLog(@"%f, %f", gyroSensitivity, accelerometerSensitivity);
    }
    
    return self;
}

- (NSString *)stringValue
{
    NSString *value = [NSString stringWithFormat:@"[%f %f %f %f] [%f %f %f] [%f %f %f] %d",
                       [quaternionValues[0] floatValue],
                       [quaternionValues[1] floatValue],
                       [quaternionValues[2] floatValue],
                       [quaternionValues[3] floatValue],
                       [gyroValues[0] floatValue],
                       [gyroValues[1] floatValue],
                       [gyroValues[2] floatValue],
                       [accelerometerValues[0] floatValue],
                       [accelerometerValues[1] floatValue],
                       [accelerometerValues[2] floatValue],
                       intervalValues];
    return value;
}

- (NSData *)extractHeaderData
{
    return [rawData subdataWithRange:NSMakeRange(0, 1)];
}

- (NSMutableArray *)extractQuaternionData
{
    NSMutableArray *quaternionBytes = [[NSMutableArray alloc] init];
    
    int padding = 1;
    for (int i = padding; i < 8 + padding; i = i + 2) {
        [quaternionBytes addObject:[rawData subdataWithRange:NSMakeRange(i, 2)]];
    }
    
    return quaternionBytes;
}

- (NSMutableArray *)extractGyroData
{
    NSMutableArray *gyroBytes = [[NSMutableArray alloc] init];
    
    int padding = 1 + 8;
    for (int i = padding; i < 6 + padding; i = i + 2) {
        [gyroBytes addObject:[rawData subdataWithRange:NSMakeRange(i, 2)]];
    }
    
    return gyroBytes;
}

- (NSMutableArray *)extractAccelerometerData
{
    NSMutableArray *accelerometerBytes = [[NSMutableArray alloc] init];
    
    int padding = 1 + 8 + 6;
    for (int i = padding; i < 6 + padding; i = i + 2) {
        [accelerometerBytes addObject:[rawData subdataWithRange:NSMakeRange(i, 2)]];
    }
    
    return accelerometerBytes;
}

- (NSData *)extractIntervalData
{
    int padding = 1 + 8 + 6 + 6;
    return [rawData subdataWithRange:NSMakeRange(padding, 2)];
}

- (NSMutableArray *)decodeQuaternionFromRaw
{
    NSMutableArray *decodedQuaternion = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [quaternionData count]; i++) {
        [decodedQuaternion addObject:[NSNumber numberWithFloat:[self decode16bitFloatFromRaw:quaternionData[i]] / 16384.0f]];
        // divided by 16384 to convert raw value to unit value
    }
    
    quaternionW = [[decodedQuaternion objectAtIndex:0] floatValue];
    quaternionX = [[decodedQuaternion objectAtIndex:1] floatValue];
    quaternionY = [[decodedQuaternion objectAtIndex:2] floatValue];
    quaternionZ = [[decodedQuaternion objectAtIndex:3] floatValue];
    
    return decodedQuaternion;
}

- (void)calculateRotationalMatrix
{
    double gravity[3];
    gravity[0] = 2 * (quaternionX * quaternionZ - quaternionW * quaternionY);
    gravity[1] = 2 * (quaternionW * quaternionX + quaternionY * quaternionZ);
    gravity[2] = quaternionW * quaternionW - quaternionX * quaternionX - quaternionY * quaternionY + quaternionZ * quaternionZ;
    
    yaw = atan2(2 * quaternionX * quaternionY - 2 * quaternionW * quaternionZ, 2 * quaternionW * quaternionW + 2 * quaternionX * quaternionX - 1);
    pitch = atan2(2 * quaternionX * quaternionW - 2 * quaternionY * quaternionZ, 1 - 2 * quaternionX * quaternionX - 2 * quaternionZ * quaternionZ);
    roll = atan2(2 * quaternionY * quaternionW - 2 * quaternionX * quaternionZ, 1 - 2 * quaternionY * quaternionY - 2 * quaternionZ * quaternionZ);
//    pitch = atanf(gravity[0] / sqrtf(gravity[1] * gravity[1] + gravity[2] * gravity[2]));
//    roll = atanf(gravity[1] / sqrtf(gravity[0] * gravity[0] + gravity[2] * gravity[2]));
}

- (NSMutableArray *)decodeGyroFromRaw
{
    NSMutableArray *decodedGyro = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [gyroData count]; i++) {
        [decodedGyro addObject:[NSNumber numberWithFloat:[self decode16bitFloatFromRaw:gyroData[i]] / gyroSensitivity]];
    }
    
    gyroX = [[decodedGyro objectAtIndex:0] floatValue];
    gyroY = [[decodedGyro objectAtIndex:1] floatValue];
    gyroZ = [[decodedGyro objectAtIndex:2] floatValue];
    
    return decodedGyro;
}

- (NSMutableArray *)decodeAccelerometerFromRaw
{
    NSMutableArray *decodedAccelerometer = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [accelerometerData count]; i++) {
        [decodedAccelerometer addObject:[NSNumber numberWithFloat:[self decode16bitFloatFromRaw:accelerometerData[i]] * pow(10, 3) /accelerometerSensitivity]];
        // multiply raw value to 10^3 to convert from g to mg
    }
    
    accelerateX = [[decodedAccelerometer objectAtIndex:0] floatValue];
    accelerateY = [[decodedAccelerometer objectAtIndex:1] floatValue];
    accelerateZ = [[decodedAccelerometer objectAtIndex:2] floatValue];
    
    return decodedAccelerometer;
}

- (uint16_t)decodeIntervalFromRaw
{
    return CFSwapInt16LittleToHost((uint16_t)intervalData);
}

- (void)setupSensorParameterFromHeader
{
    float gyroSensitivities[4] = {131.0, 65.5, 32.75, 16.375};
    float accelerometerSensitivities[4] = {16384.0, 8192.0, 4096.0, 2048.0};
    
    NSData *gyroSensitivityFlag = [self AND:headerData with:gyroSensitiveMask];
    const unsigned char *gyroSensitivityBytes = [gyroSensitivityFlag bytes];
    int gyroSensitivityIndex = (uint16_t)gyroSensitivityBytes[0];
    gyroSensitivityIndex = gyroSensitivityIndex >> 2;
    gyroSensitivity = gyroSensitivities[gyroSensitivityIndex];
    
    NSData *accelerometerSensitivityFlag = [self AND:headerData with:accelerometerSensitiveMask];
    const unsigned char *accelerometerSensitivityBytes = [accelerometerSensitivityFlag bytes];
    int accelerometerSensitivityIndex = accelerometerSensitivityBytes[0];
    accelerometerSensitivity = accelerometerSensitivities[accelerometerSensitivityIndex];
    
    NSData *quaternionEffectiveFlag = [self AND:headerData with:quaternionEffectiveMask];
    const unsigned char *quaternionEffectiveBytes = [quaternionEffectiveFlag bytes];
    int quaternionEffectiveValue = quaternionEffectiveBytes[0];
    quaternionEffectiveValue = quaternionEffectiveValue >> 6;
    if (quaternionEffectiveValue == 1) {
        quaternionEffective = YES;
    }
    
    NSData *gyroEffectiveFlag = [self AND:headerData with:gyroEffectiveMask];
    const unsigned char *gyroEffectiveBytes = [gyroEffectiveFlag bytes];
    int gyroEffectiveValue = gyroEffectiveBytes[0];
    gyroEffectiveValue = gyroEffectiveValue >> 5;
    if (gyroEffectiveValue == 1) {
        gyroEffective = YES;
    }
    
    NSData *accelerometerEffectiveFlag = [self AND:headerData with:accelerometerEffectiveMask];
    const unsigned char *accelerometerEffectiveBytes = [accelerometerEffectiveFlag bytes];
    int accelerometerEffectiveValue = accelerometerEffectiveBytes[0];
    accelerometerEffectiveValue = accelerometerEffectiveValue >> 4;
    if (accelerometerEffectiveValue == 1) {
        accelerometerEffective = YES;
    }
}

- (NSData *) AND:(NSData *)data1 with:(NSData *)data2
{
    const char *bytes1 = [data1 bytes];
    const char *bytes2 = [data2 bytes];
    
    NSMutableData *result = [[NSMutableData alloc] init];
    for (int i = 0; i < data1.length; i++){
        const char andByte = bytes1[i] & bytes2[i];
        [result appendBytes:&andByte length:1];
    }
    return result;
}

- (float)decode16bitFloatFromRaw:(NSData *)data
{
    const SInt16 *byteArray = [data bytes];
    int value = byteArray[0];
    return (float)value;
    //return (float)CFSwapInt16LittleToHost(*(int*)([data bytes]));
}

@end
