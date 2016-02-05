//
//  UIView+Center.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/16/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import UIKit

extension UIView {
//    var center : CGPoint {
//        get {
////            Swift.print(self.frame, CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2)))
//            return CGPoint(x: self.frame.origin.x + (self.frame.width / 2), y: self.frame.origin.y + (self.frame.height/2))
//        }
//    }
    
    func fade(toAlpha alpha: CGFloat) {
        dispatch_async(dispatch_get_main_queue(), {
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
            CATransaction.setAnimationDuration(0.25)
            if self.hidden && alpha == 1 {
                self.hidden = false
            }
            
            self.alpha = alpha

            CATransaction.setCompletionBlock({
                if alpha == 0 {
                    self.hidden = true
                }
            })

        })
    }
}
