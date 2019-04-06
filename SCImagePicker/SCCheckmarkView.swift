//
//  SCCheckmarkView.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

class SCCheckmarkView: UIView {

    var borderWidth = CGFloat(1.0)
    var checkMarkLineWidth = CGFloat(1.2)
    var borderColor = UIColor.white
    var bodyColor = UIColor(red: 20.0/255.0, green: 111.0/255.0, blue: 223.0/255.0, alpha: 1.0)
    var checkmarkColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 2.0
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        borderColor.setFill()
        UIBezierPath(ovalIn: bounds).fill()
        
        bodyColor.setFill()
        UIBezierPath(ovalIn: bounds.insetBy(dx: borderWidth, dy: borderWidth)).fill()
        
        // Checkmark
        let checkmarkPath = UIBezierPath()
        checkmarkPath.lineWidth = checkMarkLineWidth
        checkmarkPath.move(to: CGPoint(x: bounds.width * (6.0 / 24.0), y: bounds.height * (12.0 / 24.0)))
        checkmarkPath.addLine(to: CGPoint(x: bounds.width * (10.0 / 24.0), y: bounds.height * (16.0 / 24.0)))
        checkmarkPath.addLine(to: CGPoint(x: bounds.width * (18.0 / 24.0), y: bounds.height * (8.0 / 24.0)))
        
        checkmarkColor.setStroke()
        checkmarkPath.stroke()
    }
}
