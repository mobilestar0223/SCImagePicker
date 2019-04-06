//
//  NSIndexSet+Utility.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

extension IndexSet {
    // Get index paths
    func sc_indexPathsFromIndicesWithSection(_ section:Int) -> [IndexPath] {
        return map{IndexPath(item: $0, section: 0)}
    }
}
