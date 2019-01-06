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
    var documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    override func setUp() {
        super.setUp()
        self.images = [UIImage]()
        for i in 1..<7 {
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
    
    func testResizeUI() {
        var totalTime : CFTimeInterval = 0
        var totalCount : Double = 0
        for (i, img) in self.images.enumerated() {
            let path = "\(documentsPath)/\(i+1)_UI.png"
            print("writing to: \(path)")
            
            let ar = img.size.width/img.size.height
            let startTime = CACurrentMediaTime();
            if let resizedImage = img.resizeUI(size: CGSize(width: 320, height:Int(round(320/ar)))) {
                let endTime = CACurrentMediaTime();
                totalTime += endTime - startTime
                totalCount = totalCount + 1
                let data = resizedImage.pngData()
                try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
            }
        }
        print("Avg Time UI: ", totalTime/totalCount)
    }
    
    func testPerformanceUI() {
        if let img = self.images.last {
            let ar = img.size.width/img.size.height
                            
            self.measure {
                img.resizeUI(size: CGSize(width: 320, height:Int(round(320/ar))))
            }
        }
    }
    
    func testResizeCG() {
        var totalTime : CFTimeInterval = 0
        var totalCount : Double = 0
        for (i, img) in self.images.enumerated() {
            let path = "\(documentsPath)/\(i+1)_CG.png"
            print("writing to: \(path)")
            
            let ar = img.size.width/img.size.height
            let startTime = CACurrentMediaTime();
            if let resizedImage = img.resizeCG(size: CGSize(width: 320, height:Int(round(320/ar)))) {
                let endTime = CACurrentMediaTime();
                totalTime += endTime - startTime
                totalCount = totalCount + 1
                let data = resizedImage.pngData()
                try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
            }
        }
        print("Avg Time CG: ", totalTime/totalCount)
    }
    
    func testPerformanceCG() {
        if let img = self.images.last {
            let ar = img.size.width/img.size.height

            self.measure {
                img.resizeCG(size: CGSize(width: 320, height:Int(round(320/ar))))
            }
        }
    }
    
    func testResizeCI() {
        var totalTime : CFTimeInterval = 0
        var totalCount : Double = 0
        for (i, img) in self.images.enumerated() {
                
            let path = "\(documentsPath)/\(i+1)_CI.png"
            print("writing to: \(path)")
            
            let ar = img.size.width/img.size.height
            let startTime = CACurrentMediaTime();
            if let resizedImage = img.resizeCI(size: CGSize(width: 320, height:Int(round(320/ar)))) {
                let endTime = CACurrentMediaTime();
                totalTime += endTime - startTime
                totalCount = totalCount + 1
                let data = resizedImage.pngData()
                try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
            }
        }
        print("Avg Time CI: ", totalTime/totalCount)
    }
    
    func testPerformanceCI() {
        if let img = self.images.last {
            let ar = img.size.width/img.size.height
            
            self.measure {
                img.resizeCI(size: CGSize(width: 320, height:Int(round(320/ar))))
            }
        }
    }
    
    func testResizeVI() {
        var totalTime : CFTimeInterval = 0
        var totalCount : Double = 0
        for (i, img) in self.images.enumerated() {
            let path = "\(documentsPath)/\(i+1)_VI.png"
            print("writing to: \(path)")
            
            let ar = img.size.width/img.size.height
            let startTime = CACurrentMediaTime();
            if let resizedImage = img.resizeVI(size: CGSize(width: 320, height:Int(round(320/ar)))) {
                let endTime = CACurrentMediaTime();
                totalTime += endTime - startTime
                totalCount = totalCount + 1
                let data = resizedImage.pngData()
                try! data?.write(to: URL(fileURLWithPath:path),options: .atomic)
            }
        }
        print("Avg Time VI: ", totalTime/totalCount)
    }
    
    func testPerformanceVI() {
        if let img = self.images.last {
            let ar = img.size.width/img.size.height
            
            self.measure {
                img.resizeVI(size: CGSize(width: 320, height:Int(round(320/ar))))
            }
        }
    }
 
}
