//
//  CategoryTests.swift
//  Example
//
//  Created by Darshan Sonde on 9/1/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import XCTest

class CategoryTests: XCTestCase {

    var images : [UIImage]!
    var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    
    override func setUp() {
        super.setUp()

       //checkers of 12x12
        self.images = [UIImage]()
        self.images.append(UIImage(named: "prt.png")!) //48x60
        self.images.append(UIImage(named: "lsc.png")!) //48x60 //60x48        
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testLsc_AspectFit_Width2x() {
        for (i, img) in self.images.enumerated() {
            
            let newSize = CGSize(width: img.size.height*2, height: img.size.height)
            let resizedImage = try! img.resize(newSize: newSize, mode:.scaleAspectFit)
            
            
            let path = "\(documentsPath)/\(i+1)_Width2x.png"  
            print("Writing to \(path)")
            let data = resizedImage!.pngData()
            try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
        }
    }
    
    func testLsc_AspectFit_Height2x() {
        for (i, img) in self.images.enumerated() {
            
            let newSize = CGSize(width: img.size.width, height: img.size.width*2)
            let resizedImage = try! img.resize(newSize: newSize, mode:.scaleAspectFit)
            
            
            let path = "\(documentsPath)/\(i+1)_Height2x.png"
            print("Writing to \(path)")
            let data = resizedImage!.pngData()
            try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
        }
    }
}
