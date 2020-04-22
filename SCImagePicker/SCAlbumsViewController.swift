//
//  SCAlbumsViewController.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

/**
 Main idea comes from Apple's sample photos app
 */

import Foundation
import UIKit
import Photos

private let reuseIdentifier = "AlbumCell"

class SCAlbumsViewController: UITableViewController, SCImagePickerSubVCType {
    weak var imagePickerController:SCImagePickerController!
    var fetchResults = [PHFetchResult<PHAssetCollection>]()
    var assetCollections = [PHAssetCollection]()
    var doneButton:UIBarButtonItem!
    
    lazy var clearButton: UIBarButtonItem = {[unowned self] in
        return UIBarButtonItem(title: "Clear".localizedString, style: .plain, target: self, action: #selector(clearSelection(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        
        // Setup tool bar items
        setupToolbarItems()
        
        // Fetch User albums and smart albums
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        fetchResults = [smartAlbums, userAlbums]
        
        updateAssetCollections()
        
        // Register observer
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure navigation item
        navigationItem.title = "Photos".localizedString
        navigationItem.prompt = imagePickerController.prompt
        
        if imagePickerController.allowsMultipleSelection {
            navigationItem.rightBarButtonItem = doneButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        updateDoneButtonStatus()
        updateSelectedPhotosCountInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row, let assetsViewController = segue.destination as? SCAssetsViewController , row >= 0 && row < assetCollections.count else { return }
        
        assetsViewController.imagePickerController = imagePickerController
        assetsViewController.assetCollection = assetCollections[row]
    }

    @IBAction func cancel(_ sender:AnyObject){
        // capture value
        let picker = imagePickerController
        
        // Do cancel action if cancel.
        if let selector = picker?.pickerDelegate?.scImagePickerControllerDidCancel(_:){
            selector(imagePickerController)
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func done(_ sender:AnyObject){
        doneTapped()
    }
    
    @IBAction func clearSelection(_ sender:AnyObject){
        // Remove All Objects from selected assets
        imagePickerController.selectedAssets.removeAllObjects()
        
        // Hide tool bar
        navigationController?.setToolbarHidden(true, animated: true)
        updateDoneButtonStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SCAlbumsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SCAlbumCell
        cell.tag = (indexPath as NSIndexPath).row
        let scale = UIScreen.main.scale
        cell.borderWidth = 1.0 / scale
        
        let imageManager = PHImageManager.default()
        
        // Thumbnail
        let assetCollection = assetCollections[(indexPath as NSIndexPath).row]
        
        let options = PHFetchOptions()
        
        switch imagePickerController.mediaType {
        case .image:
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        default:
            options.predicate = NSPredicate(format: "mediaType == %ld OR mediaType == %ld", PHAssetMediaType.video.rawValue, PHAssetMediaType.image.rawValue)
        }
        
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        
        let count = fetchResult.count
        
        // ImageView 3
        if count >= 3 {
            cell.imageView3.isHidden = false
            imageManager.requestImage(
                for: fetchResult[count - 3] , 
                targetSize: cell.imageView3.frame.size * scale, contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
                    guard cell.tag == (indexPath as NSIndexPath).row else { return }
                    cell.imageView3.image = image
            })
        } else {
            cell.imageView3.isHidden = true
        }
        
        // ImageView 2
        if count >= 2 {
            cell.imageView2.isHidden = false
            imageManager.requestImage(
                for: fetchResult[fetchResult.count - 2] ,
                targetSize: cell.imageView2.frame.size * scale,
                contentMode: .aspectFill,
                options: nil, resultHandler: {image, _ in
                    guard cell.tag == (indexPath as NSIndexPath).row else { return }
                    cell.imageView2.image = image
            })
        } else {
            cell.imageView2.isHidden = true
        }
        
        // ImageView 1
        if count >= 1 {
            imageManager.requestImage(
                for: fetchResult[fetchResult.count - 1] ,
                targetSize: cell.imageView1.frame.size * scale,
                contentMode: .aspectFill,
                options: nil, resultHandler: {image, _ in
                    guard cell.tag == (indexPath as NSIndexPath).row else { return }
                    cell.imageView1.image = image
            })
        }
        
        if fetchResult.count == 0 {
            cell.imageView3.isHidden = false
            cell.imageView2.isHidden = false
            
            // Set placeholder image
            let placeholderImage = UIImage.sc_albumPlaceholderImageWithSize(cell.imageView1.frame.size)
            [cell.imageView1, cell.imageView2, cell.imageView3].forEach{$0.image = placeholderImage}
        }
        
        // Album title
        cell.titleLabel.text = assetCollection.localizedTitle
        
        // Number of photos
        cell.countLabel.text = "\(fetchResult.count)"
        
        return cell
    }
}

// MARK: - Asset Collections
extension SCAlbumsViewController {
    func updateAssetCollections(){
        let assetCollectionSubtypes = imagePickerController.assetsCollectionSubtypes
        var userAlbums = [PHAssetCollection]()
        var smartAlbums = [PHAssetCollectionSubtype:[PHAssetCollection]]()
        
        for fetchResult in fetchResults {
            fetchResult.enumerateObjects({ (assetCollection, index, _) in
                let subtype = assetCollection.assetCollectionSubtype
                if case .albumRegular = subtype {
                    userAlbums.append(assetCollection)
                } else if assetCollectionSubtypes.contains(subtype) {
                    if smartAlbums[subtype] == nil {
                        smartAlbums[subtype] = [PHAssetCollection]()
                    }
                    smartAlbums[subtype]?.append(assetCollection)
                }
            })
        }
        
        var assetCollections = [PHAssetCollection]()
        
        // Fetch smart albums
        for subtype in assetCollectionSubtypes {
            if let collections = smartAlbums[subtype] {
                assetCollections.append(contentsOf: collections)
            }
        }
        
        // Fetch user albums
        assetCollections.append(contentsOf: userAlbums)
        self.assetCollections = assetCollections
    }
}

// MRK: - PHPhotoLibraryChangeObserver
extension SCAlbumsViewController : PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async{
            // Update fetch results
            var fetchResults = self.fetchResults
            self.fetchResults.enumerated().forEach{ index, object in
                guard let changeDetails = changeInstance.changeDetails(for: object) else { return }
                fetchResults[index] = changeDetails.fetchResultAfterChanges
            }
            
            guard self.fetchResults != fetchResults else { return }
            
            self.fetchResults = fetchResults
            self.updateAssetCollections()
            self.tableView.reloadData()
        }
    }
}
