//
//  SCSlomoIconView.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

class SCSlomoIconView: UIView {
    var iconColor = UIColor.white
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        iconColor.setStroke()
        
        let width = CGFloat(2.2)
        let insetRect = rect.insetBy(dx: width / 2, dy: width / 2)
        
        // Draw dashed circle
        let circlePath = UIBezierPath(ovalIn: insetRect)
        circlePath.lineWidth = width
        circlePath.setLineDash([0.75, 0.75], count: 2, phase: 0)
        circlePath.stroke()
    }
}
