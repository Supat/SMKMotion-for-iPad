//
//  GuageView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 9/23/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import UIKit

@IBDesignable class GuageView: UIView {

    let axesDrawer = AxesDrawer.init(color: UIColor.blackColor())
    private var graphBounds = CGRectZero
    
    var plotOrigin: CGPoint = CGPointMake(0, 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    var totalBarsToDisplay: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var maxLevelToDisplay: Double = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var threshold : Double = 1;
    
    var dataStream : [CGFloat] = [0,0]
    
    private var titleField : UILabel?
    
    var title : String = "" {
        didSet {
            resizeFrameWithString(self.title)
        }
    }
    
    //TODO: Creat a class out of this
    let bar = CAGradientLayer()
    let barMask = CALayer()
    var axeLayer : SRPlotAxe?
    
    //MARK: Implementations

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleField = UILabel(frame: CGRectMake(0, 0, 0, 0))
//        titleField?.textColor = NSColor.redColor()
//        titleField?.font = NSFont.boldSystemFontOfSize(15)
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(titleField!)
        //add layout constraints to the title field
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let textFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(textFieldConstraint)
        axeLayer = SRPlotAxe(frame: self.frame, axeOrigin: CGPointZero, xPointsToShow: 1, yPointsToShow: 5)
        resizeFrameWithString(" ")
        
        
        self.layer.addSublayer((axeLayer?.layer)!)
        self.layer.addSublayer(bar)
      
        
        bar.anchorPoint = CGPoint(x: 0, y: 0)
        bar.bounds = self.bounds
        bar.colors = [UIColor.yellowColor().CGColor, UIColor.redColor().CGColor]
        bar.startPoint = CGPoint(x: 0, y: 0)
        bar.endPoint = CGPoint(x: 1, y: 0)
        
        
        barMask.backgroundColor = UIColor.blackColor().CGColor
        barMask.anchorPoint = CGPoint(x: 0, y: 0)
        barMask.bounds = bar.bounds
//        barMask.bounds.size.height = 100
        barMask.frame.origin.y = (bar.frame.size.height / 2) - (barMask.bounds.height / 2) + (titleField!.frame.height/2) - (axeLayer!.innerTopRightPadding/2)
        
//        bar.frame.origin.x = axeLayer!.innerTopRightPadding
        bar.mask = barMask
        //CALayer position is the relative position of the parent view
        
        self.layer.backgroundColor = UIColor(red: 0, green: 0 , blue: 0, alpha:  0.05).CGColor
//        self.layer.borderColor = UIColor.darkGrayColor().CGColor
//        self.layer.borderWidth = 1

        //set left padding
//        self.axeLayer?.padding.x = 10
//        bar.frame.origin.x = 10
    }
    
    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)
        
//        graphBounds = self.bounds
    }
    
    func add(data: Double) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1/60)
        barMask.bounds.size.width = (self.frame.width) * CGFloat(minMaxNormalization(Double(data), min: 0, max: threshold))
        CATransaction.commit()
    }
    
    
    //MARK: NSView delegates
    override func layoutSubviews() {
        self.axeLayer?.contentsScale = UIScreen.mainScreen().scale
        self.axeLayer?.rescaleSublayers()
        self.axeLayer?.layer.frame = self.bounds
        bar.frame = self.bounds
        barMask.frame = self.bounds
        barMask.bounds.size.height = self.bounds.height * 0.5
        barMask.frame.origin.y = (bar.frame.size.height / 2) - ( bar.frame.size.height * 0.25 )


    }


    private func minMaxNormalization(input: Double, min: Double, max: Double) -> Double {
        return ((input - min)/(max - min)) * (1 - 0) + (0);
    }
    
    private func resizeFrameWithString(title: String) {
        let nsTitle = title as NSString
        let textSize = nsTitle.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)])
        self.titleField?.text = title
        self.titleField?.frame = CGRectMake(self.bounds.width/2 - textSize.width/2, 0, textSize.width, textSize.height)
        self.titleField?.sizeToFit()
        
        var axeBounds = self.bounds
        axeBounds.origin.y = self.titleField!.frame.height
        axeLayer?.layer.frame.origin = axeBounds.origin
        axeLayer?.layer.frame.size.height = self.frame.height - self.titleField!.frame.height - self.axeLayer!.innerTopRightPadding
        axeLayer?.layer.setNeedsDisplay()
        //        Swift.print(axeLayer?.layer.bounds)
        //        axeBounds.origin.y = titleField!.bounds.height
        
        //        Swift.print(axeBounds)
    }
    
}
