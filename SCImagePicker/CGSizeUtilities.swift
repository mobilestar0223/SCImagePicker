//
//  CGSizeUtilities.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

// CGSize scale operator
func *(lhs:CGSize, rhs:CGFloat) -> CGSize{
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}
