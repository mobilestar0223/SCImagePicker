//
//  SCAssetCell.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

class SCAssetCell: UICollectionViewCell {
    var representedAssetIdentifier: String = ""
    var showsOverlayViewWhenSelected = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoIndicatorView: SCVideoIndicatorView!
    @IBOutlet weak var overlayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool{
        set {
            super.isSelected = newValue
            overlayView.isHidden = !(newValue && showsOverlayViewWhenSelected)
        }
        
        get {
            return super.isSelected
        }
    }

}
