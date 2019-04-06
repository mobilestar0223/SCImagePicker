//
//  SCVideoIndicatorView.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

class SCVideoIndicatorView : UIView {
    @IBOutlet weak var durationLabel:UILabel!
    @IBOutlet weak var videoIcon:SCVideoIconView!
    @IBOutlet weak var slomoIcon:SCSlomoIconView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
