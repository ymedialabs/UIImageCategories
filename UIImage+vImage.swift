//
//  UIImage+vImage.swift
//  Example
//
//  Created by Darshan Sonde on 31/08/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import UIKit
import Accelerate

enum UIImageResizeError : Error {
    case UnsupportedContentMode
}

//Not yet ready, please don't use this code. not tested.
extension UIImage {
    func resize(newSize:CGSize, mode:UIView.ContentMode = .scaleToFill) throws -> UIImage? {
        
        let horizontalRatio = newSize.width / self.size.width;
        let verticalRatio = newSize.height / self.size.height;
        var ratio: CGFloat = 1.0;
        
        if mode == .scaleAspectFill {
            ratio = max(horizontalRatio, verticalRatio)
        } else if mode == .scaleAspectFit {
            ratio = min(horizontalRatio, verticalRatio)
        } else if mode == .scaleToFill {
        } else {
            throw UIImageResizeError.UnsupportedContentMode
        }
        
        let newSize = CGSize(width:newSize.width * ratio, height:newSize.height * ratio)
        
        guard let cgImage = self.cgImage else { return nil }
        
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            sourceBuffer.data.deallocate()
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(newSize.width)
        let destHeight = Int(newSize.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // create a CGImage from vImage_Buffer
        let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }
        
        // create a UIImage
        let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
        return resizedImage
    }
}
