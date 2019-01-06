import UIKit
import CoreImage
import Accelerate

extension UIImage {
    func resizeUI(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension UIImage {
    func resizeCG(size:CGSize) -> UIImage? {
        if let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace {
            if let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) {
                context.interpolationQuality = .high
                context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))

                return context.makeImage().flatMap { UIImage(cgImage: $0) }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension UIImage {
    func resizeCI(size:CGSize) -> UIImage? {
        let scale = (Double)(size.width) / (Double)(self.size.width)
        let image = UIKit.CIImage(cgImage:self.cgImage!)
            
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
        let outputImage = filter.value(forKey: kCIOutputImageKey) as! UIKit.CIImage
        
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        if let contextImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let resizedImage = UIImage(cgImage: contextImage)
            return resizedImage
        } else {
            return nil
        }
    }
}

extension UIImage {
    func resizeVI(size:CGSize) -> UIImage? {
        let cgImage = self.cgImage!
            
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
            let destWidth = Int(size.width)
            let destHeight = Int(size.height)
        var bytesPerPixel = 0
        if let theCGImage = self.cgImage {
            bytesPerPixel = theCGImage.bitsPerPixel / 8
        }
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
