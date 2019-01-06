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
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    //https://stackoverflow.com/a/52987944/1067147
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Error: \(info)")
            return
        }
        
        self.topImage.image = selectedImage
        
        self.bottomImage.image = try! self.topImage.image?.resize(newSize: CGSize(width: 1000, height: 1000))
        
        picker.dismiss(animated: true, completion: nil)
    }
}

