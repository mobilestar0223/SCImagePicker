//
//  UICollectionView+Utility.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

// MARK: - IndexPaths Utility
extension UICollectionView {
    // Return indexPaths included in rectangle
    func sc_indexPathsForElementsInRect(_ rect:CGRect) -> [IndexPath]{
        guard let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)
            , allLayoutAttributes.count > 0 else {
                return []
        }
        return allLayoutAttributes.map{$0.indexPath}
    }
}

extension UICollectionView {
    /**
     Cell Size utility for Square cell.
     Should be called when bounds of this collection view is valid.
     This function also considers content inset of this collection view.
     - Parameter approxWidth : Approximate width(height) of cell which is big enough for current device model
     - Parameter spacing : Spacing between cells (For ex. it can be minimumInteritemSpacing of UICollectionViewFlowLayout), For photo like apps.
     - Returns: cell size with fits current collection view
     */
    func sc_cellSize(_ approxWidth:CGFloat, spacing:CGFloat) -> CGSize{
        let viewWidth = bounds.width - contentInset.left - contentInset.right
        let count = Int((viewWidth + spacing) / approxWidth)
        if count == 0 {
            return CGSize(width: viewWidth, height: viewWidth)
        }
        
        let cellWidth = (viewWidth + spacing) / CGFloat(count) - spacing
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    /**
     Reasonable cell size for photo tiles.
     */
    static var sc_reasonableCellSizeForImages:CGFloat {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        switch screenWidth {
        case 320:  //3.5Inch, 4Inch
            return 75
        case 375:  //4.7 Inch
            return 90
        case 414:  //
            return 100
        case 768:
            return 150
        case 1024:
            return 150
        default:
            return 150
        }
    }
}
