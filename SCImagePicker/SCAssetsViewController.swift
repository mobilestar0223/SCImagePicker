//
//  SCAssetsViewController.swift
//  SCImagePicker
//
//  Created by Alex on 21/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

/**
 Main idea comes from Apple's sample photos app
 */
import UIKit
import Photos

private let reuseIdentifier = "AssetCell"
private let reusableViewIdentifier = "FooterView"

class SCAssetsViewController: UICollectionViewController, SCImagePickerSubVCType {
    var assetCollection:PHAssetCollection!{
        didSet {
            updateFetchRequest()
            collectionView?.reloadData()
        }
    }
    
    var doneButton:UIBarButtonItem!
    
    // Asset collection
    var previousPreheatRect = CGRect.zero
    
    var assetsFetchResults:PHFetchResult<PHAsset>!       // Asset fetched results.
    weak var imagePickerController:SCImagePickerController!     // ImagePickerController
    var _thumbnailSize:CGSize = CGSize(width: 100, height: 100)     //Thumbnail size for fetching image (initially 100 x 100)
    var lastSelectedItemIndexPath:IndexPath?
    
    var disableScrollToBottom = false
    
    lazy var imageManager:PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    lazy var clearButton: UIBarButtonItem = {[unowned self] in
        return UIBarButtonItem(title: "Clear".localizedString, style: .plain, target: self, action: #selector(clearSelection(_:)))
    }()
    
    var autoDeselectEnabled: Bool {
        return imagePickerController.maximumNumberOfSelection == 1 && imagePickerController.maximumNumberOfSelection >= imagePickerController.minimumNumberOfSelection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        
        setupToolbarItems()
        resetCachedAssets()
        
        // Register Observer
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = assetCollection.localizedTitle
        navigationItem.prompt = imagePickerController.prompt
        
        collectionView?.allowsMultipleSelection = imagePickerController.allowsMultipleSelection
        
        if imagePickerController.allowsMultipleSelection {
            navigationItem.rightBarButtonItem = doneButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        updateDoneButtonStatus()
        updateSelectedPhotosCountInfo()
        collectionView?.reloadData()
        
        if assetsFetchResults.count > 0 && isMovingToParent && !disableScrollToBottom {
            let indexPath = IndexPath(row: assetsFetchResults.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableScrollToBottom = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        disableScrollToBottom = false
        // Update cached assets
        updateCachedAssets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
        guard let indexPath = collectionView?.indexPathsForVisibleItems.last else { return }
        coordinator.animate(alongsideTransition: nil){[weak self] _ in
            self?.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    @IBAction func done(_ sender:AnyObject){
        doneTapped()
    }
    
    @IBAction func clearSelection(_ sender:AnyObject){
        // Remove All Objects from selected assets
        imagePickerController.selectedAssets.removeAllObjects()
        
        if let collectionView = collectionView, let paths = collectionView.indexPathsForSelectedItems{
            paths.forEach{
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
        
        // Hide tool bar
        navigationController?.setToolbarHidden(true, animated: true)
        updateDoneButtonStatus()
    }
}

// MARK: - Assets & CacheManagement
extension SCAssetsViewController {
    func updateFetchRequest(){
        if let assetCollection = assetCollection {
            let options = PHFetchOptions()
            switch imagePickerController.mediaType {
            case .image:
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            case .video:
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            default:
                break
            }
            
            self.assetsFetchResults = PHAsset.fetchAssets(in: assetCollection, options: options)
            
            if autoDeselectEnabled && imagePickerController.selectedAssets.count > 0 {
                let asset = imagePickerController.selectedAssets.firstObject!
                let assetIndex = assetsFetchResults.index(of: asset as! PHAsset)
                lastSelectedItemIndexPath = IndexPath(item: assetIndex, section: 0)
            }
        } else {
            assetsFetchResults = nil
        }
    }
    
    func resetCachedAssets(){
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    func updateCachedAssets(){
        guard let collectionView = collectionView , (self.isViewLoaded && self.view.window != nil) else { return }
        
        // The preheat window is twice the height of the visible rect
        var preheatRect = collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0, dy: -0.5 * preheatRect.height)
        
        // If scrolled by a "reasonable" amount...
        let delta = abs(preheatRect.minY - previousPreheatRect.midY)
        
        if delta > collectionView.bounds.height / 3.0 {
            let differences = computeDifferenceBetweenRect(previousPreheatRect, newRect: preheatRect)
            let addedIndexPaths = differences.added.map{collectionView.sc_indexPathsForElementsInRect($0)}.reduce([], +)
            let removedIndexPaths = differences.removed.map{collectionView.sc_indexPathsForElementsInRect($0)}.reduce([], +)
            
            imageManager.startCachingImages(
                for: assetsAtIndexPath(addedIndexPaths),
                targetSize: _thumbnailSize,
                contentMode: .aspectFill,
                options: nil)
            
            
            imageManager.stopCachingImages(
                for: assetsAtIndexPath(removedIndexPaths),
                targetSize: _thumbnailSize,
                contentMode: .aspectFill,
                options: nil)
        }
        
        // Update previous preheat rect
        previousPreheatRect = preheatRect
    }
    
    private func assetsAtIndexPath(_ indexPaths:[IndexPath]) -> [PHAsset]{
        guard let assetsFetchResults = assetsFetchResults else { return [] }
        return indexPaths.flatMap{
            guard ($0 as NSIndexPath).row < assetsFetchResults.count else { return  nil }
            return assetsFetchResults[($0 as NSIndexPath).row]
        }
    }
    
    private func computeDifferenceBetweenRect(_ oldRect:CGRect, newRect:CGRect) -> (removed:[CGRect], added:[CGRect]) {
        guard newRect.intersects(oldRect) else {
            return (removed:[oldRect], added:[newRect])
        }
        
        var removed = [CGRect]()
        var added = [CGRect]()
        
        if newRect.maxY > oldRect.maxY {
            added.append(CGRect(x: newRect.origin.x, y: oldRect.maxY, width: newRect.size.width, height: (newRect.maxY - oldRect.maxY)))
        }
        
        if oldRect.minY > newRect.minY {
            added.append(CGRect(x: newRect.origin.x, y: newRect.minY, width: newRect.size.width, height: (oldRect.minY - newRect.minY)))
        }
        
        if newRect.maxY < oldRect.maxY {
            removed.append(CGRect(x: newRect.origin.x, y: newRect.maxY, width: newRect.size.width, height: (oldRect.maxY - newRect.maxY)))
        }
        
        if oldRect.minY < newRect.minY{
            removed.append(CGRect(x: newRect.origin.x, y: oldRect.minY, width: newRect.size.width, height: (newRect.minY - oldRect.minY)))
        }
        return (removed:removed, added:added)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewFlowLayoutDelegate
extension SCAssetsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SCAssetCell
        cell.showsOverlayViewWhenSelected = imagePickerController.allowsMultipleSelection
        
        let asset = assetsFetchResults[(indexPath as NSIndexPath).row] 
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let targetSize = itemSize * UIScreen.main.scale
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil){ image, _ in
            guard cell.representedAssetIdentifier == asset.localIdentifier else { return }
            cell.imageView.image = image
        }
        
        if case .video = asset.mediaType {
            cell.videoIndicatorView.isHidden = false
            
            let minutes = Int(asset.duration / 60.0)
            let seconds = Int(ceil(asset.duration - 60.0 * Double(minutes)))
            cell.videoIndicatorView.durationLabel.text = String(format: "%02ld:%02ld", minutes, seconds)
            
            if asset.mediaSubtypes.contains(.videoHighFrameRate){
                cell.videoIndicatorView.videoIcon.isHidden = true
                cell.videoIndicatorView.slomoIcon.isHidden = false
            } else {
                cell.videoIndicatorView.videoIcon.isHidden = false
                cell.videoIndicatorView.slomoIcon.isHidden = true
            }
        } else {
            cell.videoIndicatorView.isHidden = true
        }
        
        // Selection state
        if imagePickerController.selectedAssets.contains(asset) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else { return UICollectionReusableView() }
        
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusableViewIdentifier, for: indexPath)
        
        // Number of assets
        let label = footerView.viewWithTag(1) as! UILabel
        let numberOfPhotos = assetsFetchResults.countOfAssets(with: .image)
        let numberOfVideos = assetsFetchResults.countOfAssets(with: .video)
        
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        
        switch imagePickerController.mediaType {
        case .any:
            label.text = String(format: "%d Photos, %d Videos".localizedString, numberOfPhotos, numberOfVideos)
        case .image:
            label.text = String(format: "%d photos".localizedString, numberOfPhotos)
        case .video:
            label.text = String(format: "%d videos".localizedString, numberOfVideos)
        }
        
        return footerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAssets = imagePickerController.selectedAssets
        let asset = assetsFetchResults[(indexPath as NSIndexPath).item] 
        if imagePickerController.allowsMultipleSelection {
            if autoDeselectEnabled && selectedAssets.count > 0 {
                selectedAssets.removeObject(at: 0)
                
                // Deselect previous selected asset
                if let lastSelectedItemIndexPath = lastSelectedItemIndexPath {
                    collectionView.deselectItem(at: lastSelectedItemIndexPath, animated: false)
                }
            }
            
            // Add asset to set
            selectedAssets.add(asset)
            
            lastSelectedItemIndexPath = indexPath
            updateDoneButtonStatus()
            if imagePickerController.showsNumberOfSelectedAssets {
                updateSelectedPhotosCountInfo()
                
                if selectedAssets.count == 1 {
                    navigationController?.setToolbarHidden(false, animated: true)
                }
            }
        } else {
            if let selector = imagePickerController.pickerDelegate?.scImagePickerController(_:didFinishPickingAssets:){
                selector(imagePickerController, [asset])
            } else {
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        }
        imagePickerController.pickerDelegate?.scImagePickerController?(imagePickerController, didSelectAsset: asset)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard imagePickerController.allowsMultipleSelection else { return }
        
        let selectedAssets = imagePickerController.selectedAssets
        
        let asset = assetsFetchResults[(indexPath as NSIndexPath).item] 
        
        // Remove asset form set
        selectedAssets.remove(asset)
        
        lastSelectedItemIndexPath = nil
        
        updateDoneButtonStatus()
        if imagePickerController.showsNumberOfSelectedAssets {
            updateSelectedPhotosCountInfo()
            
            if selectedAssets.count == 0 {
                navigationController?.setToolbarHidden(true, animated: true)
            }
        }
        imagePickerController.pickerDelegate?.scImagePickerController?(imagePickerController, didDeselectAsset: asset)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let asset = assetsFetchResults[(indexPath as NSIndexPath).row] 
        
        // Check delegate first
        if let shouldSelectAsset = imagePickerController.pickerDelegate?.scImagePickerController?(imagePickerController, shouldSelectAsset: asset) , !shouldSelectAsset {
            return false
        }
        
        // Even delegate returned true, check maximum photos count & auto deselect
        if autoDeselectEnabled {
            return true
        }
        
        return !maximumSelectionLimitReached
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SCAssetsViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.sc_cellSize(UICollectionView.sc_reasonableCellSizeForImages, spacing: 1.0)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension SCAssetsViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: assetsFetchResults) else { return }
        DispatchQueue.main.async{ [weak self] in
            self?.updateAssetsWithChanges(changes)
        }
    }
    
    private func updateAssetsWithChanges(_ changes:PHFetchResultChangeDetails<PHAsset>){
        guard let collectionView = collectionView else { return }
        // Get the new fetched results
        assetsFetchResults = changes.fetchResultAfterChanges
        
        // Should reset cached assets after
        defer {
            resetCachedAssets()
        }
        
        guard changes.hasIncrementalChanges && !changes.hasMoves else {
            collectionView.reloadData()
            return
        }
        
        // Perform batch updates
        collectionView.performBatchUpdates({
            if let removedIndexes = changes.removedIndexes , removedIndexes.count > 0{
                collectionView.deleteItems(at: removedIndexes.sc_indexPathsFromIndicesWithSection(0))
            }
            
            if let insertedIndexes = changes.insertedIndexes , insertedIndexes.count > 0 {
                collectionView.insertItems(at: insertedIndexes.sc_indexPathsFromIndicesWithSection(0))
            }
            
            if let changedIndexes = changes.changedIndexes , changedIndexes.count > 0 {
                collectionView.reloadItems(at: changedIndexes.sc_indexPathsFromIndicesWithSection(0))
            }
            }, completion: nil)
    }
}
