//
//  SCImagePickerSubVCType.swift
//  SCImagePicker
//
//  Created by Alex on 24/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import Photos

protocol SCImagePickerSubVCType {
    var doneButton:UIBarButtonItem! { get }
    var imagePickerController:SCImagePickerController! { get }
    var clearButton:UIBarButtonItem { get }
}

extension SCImagePickerSubVCType where Self:UIViewController {
    var minimumSelectionLimitFulfilled:Bool{
        return imagePickerController.minimumNumberOfSelection <= imagePickerController.selectedAssets.count
    }
    
    var maximumSelectionLimitReached: Bool{
        let minimumNumberOfSelection = max(1, imagePickerController.minimumNumberOfSelection)
        if minimumNumberOfSelection <= imagePickerController.maximumNumberOfSelection {
            return imagePickerController.maximumNumberOfSelection <= imagePickerController.selectedAssets.count
        }
        return false
    }
    
    /**
     tool bar items.
    */
    func setupToolbarItems(){
        // Space
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Info Label
        let infoBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        infoBarButtonItem.isEnabled = false
        let attribues:[NSAttributedString.Key:Any] = [NSAttributedString.Key.foregroundColor: UIColor.black]

        infoBarButtonItem.setTitleTextAttributes(attribues, for: [.normal])
        infoBarButtonItem.setTitleTextAttributes(attribues, for: [.disabled])
        
        toolbarItems = [clearButton, leftSpace, infoBarButtonItem, rightSpace]
    }
    
    /**
     Done Button Status
    */
    func updateDoneButtonStatus(){
        doneButton.isEnabled = minimumSelectionLimitFulfilled
        clearButton.isEnabled = imagePickerController.selectedAssets.count > 0
    }
    
    /**
     Selected Photos Count Information
    */
    func updateSelectedPhotosCountInfo(){
        let selectedAssets = imagePickerController.selectedAssets
        if selectedAssets.count > 0 {
            toolbarItems?[2].title = String(format: "%d Items Selected".localizedString, selectedAssets.count)
        } else {
            toolbarItems?[2].title = ""
        }
    }
    
    /**
     When done tapped
    */
    func doneTapped(){
        if let selector = imagePickerController.pickerDelegate?.scImagePickerController(_:didFinishPickingAssets:){
            selector(imagePickerController, imagePickerController.selectedAssets.flatMap{$0 as? PHAsset})
        } else {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
    }
}
