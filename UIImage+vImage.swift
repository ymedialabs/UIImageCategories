//
//  UIImage+vImage.swift
//  Example
//
//  Created by Darshan Sonde on 31/08/16.
//  Copyright © 2016 Y Media Labs. All rights reserved.
//

import UIKit
import Accelerate

enum UIImageError : ErrorType {
    case UnsupportedContentMode
}

extension UIImage {
    func resize(newSize:CGSize, mode:UIViewContentMode = .ScaleToFill) throws -> UIImage? {
        
        let horizontalRatio = newSize.width / self.size.width;
        let verticalRatio = newSize.height / self.size.height;
        var ratio: CGFloat = 1.0;
        
        if mode == .ScaleAspectFill {
            ratio = max(horizontalRatio, verticalRatio)
        } else if mode == .ScaleAspectFit {
            ratio = min(horizontalRatio, verticalRatio)
        } else if mode == .ScaleToFill {
        } else {
            throw UIImageError.UnsupportedContentMode
        }
        
        let newSize = CGSize(width:newSize.width * ratio, height:newSize.height * ratio)
        
        guard let cgImage = self.CGImage else { return nil }
        
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.First.rawValue),
                                          version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.RenderingIntentDefault)
        var sourceBuffer = vImage_Buffer()
        defer {
            sourceBuffer.data.dealloc(Int(sourceBuffer.height) * Int(sourceBuffer.height) * 4)
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        // create a destination buffer
        let scale = self.scale
        let destWidth = Int(newSize.width)
        let destHeight = Int(newSize.height)
        let bytesPerPixel = CGImageGetBitsPerPixel(cgImage) / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.alloc(destHeight * destBytesPerRow)
        defer {
            destData.dealloc(destHeight * destBytesPerRow)
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // create a CGImage from vImage_Buffer
        let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }
        
        // create a UIImage
        let resizedImage = destCGImage.flatMap { UIImage(CGImage: $0, scale: 0.0, orientation: self.imageOrientation) }
        return resizedImage
    }
    
    func crop(bounds:CGRect) -> UIImage? {
        return nil
    }
}