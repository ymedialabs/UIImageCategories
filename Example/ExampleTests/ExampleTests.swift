//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Darshan Sonde on 28/08/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import XCTest
@testable import Example

class ExampleTests: XCTestCase {
    
    var images : [UIImage]!
    
    override func setUp() {
        super.setUp()
        self.images = [UIImage]()
        for i in 1..<6 {
            if let img = UIImage(named: "\(i).jpg") {
                self.images.append(img)
            } else if let img = UIImage(named: "\(i).png") {
                self.images.append(img)
            } 
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]        
        for alg in ["UI", "CG"] {
        for (i, img) in self.images.enumerate() {
            
            let path = "\(documentsPath)/\(i+1)_\(alg).png"
            print("writing to: \(path)")
            
            let ar = img.size.width/img.size.height
            
            
            if let algo = UIImage.ResizeAlgo(rawValue:alg), let imgOut = img.resize(algo , size: CGSize(width: 320, height:320/ar)) {
            
                let data = UIImagePNGRepresentation(imgOut)
                try! data?.writeToFile("\(path)", options: .AtomicWrite)
            }
        }
        }
    }
    
    func testPerformanceExample() {
        self.measureBlock {
        }
    }
    
}
