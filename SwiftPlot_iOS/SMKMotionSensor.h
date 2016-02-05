//
//  SMKMotionSensor.h
//  TPHBridge
//
//  Created by Supat Saetia on 9/25/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SMKMotionData.h"
#import "SMKByteBuffer.h"

@class SMKMotionSensor;
@protocol SMKMotionSensorDelegate <NSObject>
- (void)SMKMotionSensorDidReceiveDataFromBuffer:(SMKMotionData *)data;

@optional
- (void)SMKMotionSensorDidUpdateConnectionState:(BOOL)connected;
- (void)SMKMotionSensorDidUpdateStatusMessage:(NSString *)status;

@end

@interface SMKMotionSensor : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate, SMKByteBufferDelegate>
{
    CBCentralManager *centralManager;
    CBPeripheral *m_peripheral;
    CBCharacteristic *sensorTxData_characteristic;
    CBCharacteristic *sensorControl_characteristic;
    CBCharacteristic *flowControl_characteristic;
    
    NSData *startByte;
    NSData *stopByte;
    
    CBUUID *SMKMotionDeviceDiscoverUUID;
    CBUUID *SMKControlServiceUUID;
    CBUUID *SMKSensorDataCharacteristicUUID;
    CBUUID *SMKSensorControlCharacteristicUUID;
    CBUUID *SMKFlowControlCharacteristicUUID;
    
    dispatch_queue_t centralQueue;
    
    BOOL _connectionState;
    
    SMKByteBuffer *byteBuffer;
    
}

@property (retain) id delegate;
@property (nonatomic, readonly) BOOL connectionState;

- (id)initWithDelegate:(id<SMKMotionSensorDelegate>)SMKMotionDelegate;
- (void)scanForRemoteSensor;
- (void)disconnectFromRemoteSensor;

@end
