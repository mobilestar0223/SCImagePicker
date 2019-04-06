//
//  SCImagePickerController.swift
//  SCImagePicker
//
//  Created by Alex on 22/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import Photos

public enum SCImagePickerMediaType {
    case any
    case image
    case video
}

@objc public protocol SCImagePickerControllerDelegate : class {
    @objc optional func scImagePickerController(_ imagePickerController:SCImagePickerController, didFinishPickingAssets:[PHAsset])
    @objc optional func scImagePickerControllerDidCancel(_ imagePickerController:SCImagePickerController)
    
    @objc optional func scImagePickerController(_ imagePickerController:SCImagePickerController, shouldSelectAsset:PHAsset) -> Bool
    @objc optional func scImagePickerController(_ imagePickerController:SCImagePickerController, didSelectAsset:PHAsset)
    @objc optional func scImagePickerController(_ imagePickerController:SCImagePickerController, didDeselectAsset:PHAsset)
}

public class SCImagePickerController: UINavigationController {

    // MARK: - ImagePickerController parameters
    public var allowsMultipleSelection:Bool = true
    public var mediaType = SCImagePickerMediaType.any
    public var assetsCollectionSubtypes:[PHAssetCollectionSubtype] = [.smartAlbumUserLibrary, .smartAlbumPanoramas,  .smartAlbumFavorites, .smartAlbumVideos]
    public var minimumNumberOfSelection = 1
    public var maximumNumberOfSelection = 9
    public var prompt:String? = nil
    public var showsNumberOfSelectedAssets = true
    
    private(set) var selectedAssets = NSMutableOrderedSet()
    var albumsViewController: SCAlbumsViewController!
    
    // Delegate
    public weak var pickerDelegate:SCImagePickerControllerDelegate?
    
    public init(){
        let storyboard = UIStoryboard(name: "SCImagePicker", bundle: kAssetBundle)
        let albumsViewController = storyboard.instantiateViewController(withIdentifier: "SCAlbumsViewController") as! SCAlbumsViewController
        super.init(rootViewController: albumsViewController)
        
        self.albumsViewController = albumsViewController
        // set imagePickerController
        albumsViewController.imagePickerController = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
