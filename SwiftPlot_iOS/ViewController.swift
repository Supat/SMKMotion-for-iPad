//
//  ViewController.swift
//  SwiftPlot_iOS
//
//  Created by Kalanyu Zintus-art on 1/5/16.
//  Copyright © 2016 Koikelab. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSSPlashViewDelegate, SMKMotionSensorDelegate {

//    private var sensorModule = TPHEMGSensor()
//    private var jointEstimator = KLJointAngleEstimator()
    
    private var sensorModule = SMKMotionSensor();
    

    //TODO: make this setup able when used in code
    @IBOutlet weak var graphView: SRPlotView! {
        didSet {
            graphView.title = "Gyrometer"
            graphView.totalSecondsToDisplay = 10.0
            graphView.totalChannelsToDisplay = 3
            //axe padding
            graphView.samplingRate = 60
            graphView.axeLayer?.maxDataRange = 1500
            
            graphView.yTicks[0] = "X"
            graphView.yTicks[1] = "Y"
            graphView.yTicks[2] = "Z"
        }
    }
    
    @IBOutlet weak var secondGraphView: SRPlotView! {
        didSet {
            secondGraphView.title = "Accelerometer"
            secondGraphView.totalSecondsToDisplay = 10.0
            secondGraphView.totalChannelsToDisplay = 3
            //axe padding
            secondGraphView.samplingRate = 60
            secondGraphView.axeLayer?.maxDataRange = 1500
            
            secondGraphView.yTicks[0] = "X"
            secondGraphView.yTicks[1] = "Y"
            secondGraphView.yTicks[2] = "Z"
        }
    }
    
    @IBOutlet weak var thirdGraphView: SRPlotView! {
        didSet {
            thirdGraphView.title = "Quaternion"
            thirdGraphView.totalSecondsToDisplay = 10.0
            thirdGraphView.totalChannelsToDisplay = 4
            //axe padding
            thirdGraphView.samplingRate = 60
            thirdGraphView.axeLayer?.maxDataRange = 2
            
            thirdGraphView.yTicks[0] = "W"
            thirdGraphView.yTicks[1] = "X"
            thirdGraphView.yTicks[2] = "Y"
            thirdGraphView.yTicks[3] = "Z"
        }
    }
    
    var count = 0
    
    @IBOutlet weak var backgroundView: NSSpashBGView! {
        didSet {
            backgroundView.initLayers()
            backgroundView.delegate = self
        }
    }
    
    private var anotherDataTimer: NSTimer?
    private var persistanceSensorReconnectTimer : NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        anotherDataTimer = NSTimer(timeInterval:1/60, target: self, selector: "addData2", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(anotherDataTimer!, forMode: NSRunLoopCommonModes)
        // Do any additional setup after loading the view, typically from a nib.
        self.view.layer.backgroundColor = UIColor.redColor().CGColor
        
        persistanceSensorReconnectTimer = NSTimer(timeInterval: 1/60, target: self, selector: "persistReconnectToSensor", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(persistanceSensorReconnectTimer!, forMode: NSRunLoopCommonModes)
        
        sensorModule.delegate = self
        sensorModule.scanForRemoteSensor()
        
    }

//    override func viewDidLayoutSubviews() {
//        print(self.view.frame, graphView.frame, graphView.bounds, graphView.layer.frame, graphView.layer.bounds)
//    }
    
    func addData2() {
        
//        let cgCount = Double(++count) * 1/60 % 1
        
//        graphView.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
//        stiffnessView.add(cgCount)
        
    }
    //MARK: Implementations
//    func systemStartup() {
//        loadingView.fade(toAlpha: 0)
//    }
    
    //MARK: NSSPlashViewDelegate
    func splashAnimationEnded(startedFrom from: SplashDirection) {
        //        switch self.mode {
        //        case .TV:
        //            tvIconView.fade(toAlpha: 1)
        //        case .Robot:
        //            kumamonIconView.fade(toAlpha: 1)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func TPHEMGSensorDidReceiveDataFromRemoteSensor(data: TPHData!) {
//        
//        let emgData : [Double] = [data.emgValue[0].doubleValue, data.emgValue[1].doubleValue, data.emgValue[2].doubleValue, data.emgValue[3].doubleValue, data.emgValue[4].doubleValue, data.emgValue[5].doubleValue]
//        
//        graphView.addData(emgData)
//    }
    
    func SMKMotionSensorDidReceiveDataFromBuffer(data: SMKMotionData!) {
        let gyroData : [Double] = [Double(data.gyroX), Double(data.gyroY), Double(data.gyroZ)]
        let accelData : [Double] = [Double(data.accelerateX), Double(data.accelerateY), Double(data.accelerateZ)]
        let quatData : [Double] = [Double(data.quaternionW), Double(data.quaternionX), Double(data.quaternionY), Double(data.quaternionZ)]
        
        graphView.addData(gyroData)
        secondGraphView.addData(accelData)
        thirdGraphView.addData(quatData)
    }
    
    func SMKMotionSensorDidUpdateConnectionState(connected: Bool) {
        
    }
    
    func SMKMotionSensorDidUpdateStatusMessage(status: String!) {
        
    }
    
    func persistReconnectToSensor () {
        if (!sensorModule.connectionState) {
            sensorModule.scanForRemoteSensor()
        }
    }

}

