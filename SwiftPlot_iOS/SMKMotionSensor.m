//
//  SMKMotionSensor.m
//  TPHBridge
//
//  Created by Supat Saetia on 9/25/15.
//  Copyright © 2015 Supat Saetia. All rights reserved.
//

#import "SMKMotionSensor.h"

@implementation SMKMotionSensor

@synthesize delegate;
@synthesize connectionState = _connectionState;

- (id)init
{
    self = [super init];
    if (self) {
        SMKControlServiceUUID = [CBUUID UUIDWithString:@"15F5A500-2511-11E5-867F-000190F08F1E"];
        
        SMKSensorDataCharacteristicUUID = [CBUUID UUIDWithString:@"15F5A501-2511-11E5-867F-000190F08F1E"];
        SMKSensorControlCharacteristicUUID = [CBUUID UUIDWithString:@"15F5A502-2511-11E5-867F-000190F08F1E"];
        SMKFlowControlCharacteristicUUID = [CBUUID UUIDWithString:@"15F5A503-2511-11E5-867F-000190F08F1E"];
        
        startByte = [NSData dataWithBytes:"\x01" length:1];
        stopByte = [NSData dataWithBytes:"\x02" length:1];
        
        centralQueue = dispatch_queue_create("mycentralqueue", DISPATCH_QUEUE_SERIAL);
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
        
        _connectionState = NO;
        
        byteBuffer = [[SMKByteBuffer alloc] init];
        byteBuffer.delegate = self;
    }
    return self;
}

- (id)initWithDelegate:(id<SMKMotionSensorDelegate>)SMKMotionDelegate {
    self = [super init];
    if (self) {
        self = [self init];
        self.delegate = SMKMotionDelegate;
    }
    
    return self;
}

- (void)scanForRemoteSensor
{
    BOOL centralManagerIsReady = NO;
    while (!centralManagerIsReady) {
        switch (centralManager.state) {
            case CBCentralManagerStateResetting:
                NSLog(@"Resetting connection");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStateUnsupported:
                NSLog(@"Device unsupport");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@"Unauthorized to use BLE");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@"Bluetooth is off");
                centralManagerIsReady = NO;
                break;
            case CBCentralManagerStatePoweredOn:
                NSLog(@"Bluetooth is on");
                centralManagerIsReady = YES;
                break;
                
            default:
                NSLog(@"Unknown error occured");
                centralManagerIsReady = NO;
                break;
        }
    }
    if (centralManagerIsReady) {
        [self scanForPeripherals];
    }
}

- (void)disconnectFromRemoteSensor
{
    [m_peripheral writeValue:stopByte forCharacteristic:flowControl_characteristic type:CBCharacteristicWriteWithResponse];
    [self disconnectPeripheral:m_peripheral];
}

- (void)scanForPeripherals
{
    [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:SMKControlServiceUUID] options:nil];
    NSLog(@"Start scanning");
    [[self delegate] SMKMotionSensorDidUpdateStatusMessage:@"Scanning for remote sensor..."];
}

- (void)stopScanForPerpherals
{
    [centralManager stopScan];
    NSLog(@"Scaning stopped");
    [[self delegate] SMKMotionSensorDidUpdateStatusMessage:@"Stop scanning for remote sensor"];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    [centralManager connectPeripheral:peripheral options:nil];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@", peripheral.name);
    [[self delegate] SMKMotionSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Discovered %@", peripheral.name]];
    
    m_peripheral = peripheral;
    [centralManager connectPeripheral:m_peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Encounter %@", [error localizedDescription]);
    }
    NSLog(@"Disconnected %@", peripheral.name);
    [[self delegate] SMKMotionSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Disconnected from %@", peripheral.name]];
    _connectionState = NO;
    [[self delegate] SMKMotionSensorDidUpdateConnectionState:_connectionState];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (CBCentralManagerStatePoweredOn) {
        NSLog(@"centralManager is on");
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"%@ connected", peripheral.name);
    _connectionState = YES;
    [[self delegate] SMKMotionSensorDidUpdateConnectionState:_connectionState];
    [[self delegate] SMKMotionSensorDidUpdateStatusMessage:[NSString stringWithFormat:@"Connected with %@", peripheral.name]];
    [self stopScanForPerpherals];
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error during services discovery: %@", [error localizedDescription]);
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:SMKControlServiceUUID]) {
            NSLog(@"%@ service discovered", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error during characteristics discovery for %@: %@", service.UUID, [error localizedDescription]);
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:SMKSensorDataCharacteristicUUID]) {
            NSLog(@"Discovered sensor data characteristic %@", characteristic.UUID);
            sensorTxData_characteristic = characteristic;
            [m_peripheral setNotifyValue:YES forCharacteristic:sensorTxData_characteristic];
            [[self delegate] SMKMotionSensorDidUpdateStatusMessage:@"Listening for signal"];
        }
        if ([characteristic.UUID isEqual:SMKSensorControlCharacteristicUUID]) {
            NSLog(@"Discovered sensor control characteristic %@", characteristic.UUID);
            sensorControl_characteristic = characteristic;
        }
        if ([characteristic.UUID isEqual:SMKFlowControlCharacteristicUUID]) {
            NSLog(@"Discovered flow control characteristic %@", characteristic.UUID);
            flowControl_characteristic = characteristic;
            [m_peripheral setNotifyValue:YES forCharacteristic:flowControl_characteristic];
            [m_peripheral writeValue:startByte forCharacteristic:flowControl_characteristic type:CBCharacteristicWriteWithoutResponse];
            [[self delegate] SMKMotionSensorDidUpdateStatusMessage:@"Telling sensor to start transmitting signal"];
            [[self delegate] SMKMotionSensorDidUpdateStatusMessage:@"Listening to flow control characteristic"];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error when characteristic's value is updated: %@", [error localizedDescription]);
    }
    if ([characteristic.UUID isEqual:SMKSensorDataCharacteristicUUID]) {
        NSData *data = characteristic.value;
        //NSLog(@"%@", data);
        [byteBuffer appendData:data];
        data = nil;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheral readValueForCharacteristic:characteristic];
    if (error) {
        NSLog(@"Error write value for characterist %@ %@", characteristic.UUID, [error localizedDescription]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Update notification %@", characteristic.UUID);
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
}

- (void)SMKByteBufferDidDequeueMotionData:(NSMutableData *)data error:(NSError *)error
{
    //NSLog(@"%@", data);
    SMKMotionData *motionData = [[SMKMotionData alloc] initWithRawData:data];
    [[self delegate] SMKMotionSensorDidReceiveDataFromBuffer:motionData];
    motionData = nil;
}

@end
