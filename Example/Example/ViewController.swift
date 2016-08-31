//
//  ViewController.swift
//  Example
//
//  Created by Darshan Sonde on 28/08/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cameraAction(sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.navigationController?.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.topImage.image = image
                
                self.bottomImage.image = self.topImage.image?.resizeVI(CGSize(width: 50, height: 50))
            }
        })
    }
}

