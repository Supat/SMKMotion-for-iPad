//
//  HalfCircleMeterView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/5/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import UIKit

@IBDesignable class CountView: UIView {
    
    private var titleField : UILabel?
    private var countField : UILabel?

    var title : String = "" {
        didSet {
            self.titleField?.text = self.title
        }
    }
    
    var directionValue : Int? {
        get {
            return NSNumberFormatter().numberFromString(self.countText)?.integerValue
        }
        set {
            dispatch_async(dispatch_get_main_queue(), {
                if let countNumber = NSNumberFormatter().stringFromNumber(NSNumber(integer: newValue!)) {
                    if newValue > 0 {
                        self.countText = "+\(countNumber)"
                    } else if newValue <= 0 {
                        self.countText = countNumber
                    }
                } else {
                    self.countText = "0"
                }
            })
        }
    }
    
    private var countText : String = "0" {
        didSet {
            //already has layout constraints, no need for frame adjustment
            //TODO:size adjustments for readability
            countField?.text = self.countText
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleField = UILabel(frame: CGRectZero)
        countField = UILabel(frame: CGRectZero)
        
        titleField?.textColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        countField?.textColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)

        self.addSubview(titleField!)
        self.addSubview(countField!)
        
        self.titleField?.font = UIFont.boldSystemFontOfSize(20)
        self.countField?.font = UIFont.systemFontOfSize(100)
        self.countField?.translatesAutoresizingMaskIntoConstraints = false
        var countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        countFieldConstraint = NSLayoutConstraint(item: self.countField!, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        self.addConstraint(countFieldConstraint)
        
        self.titleField?.translatesAutoresizingMaskIntoConstraints = false
        let titleFieldConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let bottomMarginConstraint = NSLayoutConstraint(item: self.titleField!, attribute: .BottomMargin, relatedBy: .Equal, toItem: self, attribute: .BottomMargin, multiplier: 1, constant: 5)
        self.addConstraint(titleFieldConstraint)
        self.addConstraint(bottomMarginConstraint)

        countField?.text = "0"
        titleField?.text = "Title"
        self.backgroundColor = UIColor.clearColor()

//        self.wantsLayer = true
//        self.layer?.backgroundColor = CGColorCreateGenericRGB(0, 0 , 0, 0.05)
//        self.layer?.borderColor = UIColor.darkGrayColor().CGColor
//        self.layer?.borderWidth = 1

    }
    
    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)


        // Drawing code here.
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        countField?.font = UIFont.boldSystemFontOfSize(resizeFontWithString(countField!.text!))
//        self.opaque = false
    }

    
    
//    
//    func setDirectionValue(direction: Int) {
//        if let countNumber = NSNumberFormatter().stringFromNumber(NSNumber(integer: direction)) {
//            if direction > 0 {
//                self.performSelectorOnMainThread("setCountTextInMainthread", withObject: "+\(countNumber)", waitUntilDone: true)
//            } else if direction <= 0 {
//                self.performSelectorOnMainThread("setCountTextInMainthread", withObject: countNumber, waitUntilDone: true)
//            }
//        } else {
//            self.performSelectorOnMainThread("setCounTextInMainthread", withObject: "0", waitUntilDone: true)
//        }
//
//    }
//    
//    func setCountTextInMainthread(text: String) {
//        self.countText = text
//    }
//    
    private func resizeFontWithString(title: String) -> CGFloat {
//        defer {
//            Swift.print(textSize, self.bounds, displaySize)
//        }
        
        let smallestSize : CGFloat = 100
        let largestSize : CGFloat = 200
        var textSize = CGSizeZero
        var displaySize = smallestSize
        
        while displaySize < largestSize {
            let nsTitle = NSString(string: title)
            let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(displaySize)]
            textSize = nsTitle.sizeWithAttributes(attributes)
            if textSize.height < self.bounds.height * 0.8 {
//                Swift.print(displaySize, "increasing")
                displaySize += 1
            } else {
                return displaySize
            }
        }
        
        return largestSize
    }
}
