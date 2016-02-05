//
//  SRMergePlotView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/20/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import UIKit

class SRMergePlotView: SRPlotView {

    var numberOfTicks : Int = 0
    var maxDataRange : Int {
        get {
            return (self.axeLayer?.maxDataRange)!
        }
        set {
            self.axeLayer?.maxDataRange = newValue * 2
            let textSize = "\(self.maxDataRange)".sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)])
                self.axeLayer?.graph.padding.x = textSize.width
                self.axeLayer?.layer.setNeedsDisplay()

        }
    }
    
    var axeOrigin = CGPointZero
    
    //MARK: Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.axeLayer!.layer.removeFromSuperlayer()
        
        self.axeLayer = SRPlotAxe(frame: self.frame, axeOrigin: CGPointZero, xPointsToShow: totalSecondsToDisplay, yPointsToShow: totalChannelsToDisplay, numberOfSubticks: 5)
        self.layer.addSublayer(self.axeLayer!.layer)
        self.axeLayer?.yPointsToShow = 1
        self.axeLayer?.graph.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        self.axeLayer?.signalType = .Merge
        
        self.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1

    }
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
    }
    
    convenience init(frame frameRect: CGRect, title: String, seconds: Double, maxRange: (CGPoint, CGPoint), samplingRatae: CGFloat, origin: CGPoint, padding: CGFloat = 0.0) {
        self.init(frame: frameRect)
        
    }
    
    // The initial position of a segment that is meant to be displayed on the left side of the graph.
    // This positioning is meant so that a few entries must be added to the segment's history before it becomes
    // visible to the user. This value could be tweaked a little bit with varying results, but the X coordinate
    // should never be larger than 16 (the center of the text view) or the zero values in the segment's history
    // will be exposed to the user.
    //
    override var kSegmentInitialPosition : CGPoint {
        get {
            //something about anchor point being 0.5
            //line width hack
            return CGPoint(x: graphAxes.position.x - graphAxes.pointsPerUnit.x, y: graphAxes.position.y + 1)
        }
    }
    
}
