//
//  String+Localization.swift
//  SCImagePicker
//
//  Created by Alex on 22/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

let kAssetBundle:Bundle = {
    var bundle:Bundle? = Bundle(for: SCImagePickerController.self)
    if let bundlePath = bundle?.path(forResource: "SCImagePicker", ofType: "bundle"){
        bundle = Bundle(path: bundlePath)
    }
    return bundle!
}()


// MARK: - Localization extension
extension String {
    var localizedString: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: kAssetBundle, comment: self)
    }
}
