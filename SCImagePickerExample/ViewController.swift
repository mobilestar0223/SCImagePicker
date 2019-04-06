//
//  ViewController.swift
//  SCImagePickerExample
//
//  Created by Alex on 23/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import SCImagePicker
import Photos

class ViewController: UIViewController {
    
    @IBAction func buttonTapped(_ sender: AnyObject) {
        let vc = SCImagePickerController()
        vc.pickerDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: SCImagePickerControllerDelegate {
    func scImagePickerControllerDidCancel(_ imagePickerController: SCImagePickerController) {
        print("cancelled")
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func scImagePickerController(_ imagePickerController: SCImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        print("Picked \(assets)")
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

