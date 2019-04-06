//
//  SCAlbumCell.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

class SCAlbumCell: UITableViewCell {
    @IBOutlet weak var imageView1:UIImageView!
    @IBOutlet weak var imageView2:UIImageView!
    @IBOutlet weak var imageView3:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var countLabel:UILabel!
    
    var borderWidth = CGFloat(0) {
        didSet {
            [imageView1, imageView2, imageView3].forEach{
                $0?.layer.borderColor = UIColor.white.cgColor
                $0?.layer.borderWidth = borderWidth
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
