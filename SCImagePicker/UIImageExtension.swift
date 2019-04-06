//
//  UIImageExtension.swift
//  SCImagePicker
//
//  Created by Alex on 23/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

extension UIImage {
    static func sc_albumPlaceholderImageWithSize(_ size:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        let backgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        let iconColor = UIColor(red: 179.0 / 255.0, green: 179.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0)
        
        // Background
        backgroundColor.setFill()
        UIBezierPath(rect: CGRect(origin: CGPoint.zero, size:size)).fill()
        
        // Icon (back)
        let backIconRect = CGRect(x: size.width * (16.0 / 68.0),
                                  y: size.height * (20.0 / 68.0),
                                  width: size.width * (32.0 / 68.0),
                                  height: size.height * (24.0 / 68.0))
        iconColor.setFill()
        UIBezierPath(
            rect: backIconRect).fill()
        
        backgroundColor.setFill()
        UIBezierPath(rect: backIconRect.insetBy(dx: 1, dy: 1)).fill()
        
        // Icon (front)
        let frontIconRect = CGRect(x: size.width * (20.0 / 68.0), y: size.height * (24.0 / 68.0), width: size.width * (32.0 / 68.0), height: size.height * (24.0 / 68.0))
        backgroundColor.setFill()
        UIBezierPath(rect: frontIconRect.insetBy(dx: -1, dy: -1)).fill()
        
        iconColor.setFill()
        UIBezierPath(rect: frontIconRect).fill()
        
        backgroundColor.setFill()
        UIBezierPath(rect: frontIconRect.insetBy(dx: 1, dy: 1)).fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
}
