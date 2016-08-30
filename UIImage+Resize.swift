import UIKit
import CoreImage
import Accelerate

extension UIImage {
    enum ResizeAlgo:String {
        case UI = "UI"
        case CG = "CG"
        case CI = "CI"
        case VI = "VI"
    }
    
    func resize(algo: ResizeAlgo, size:CGSize, mode:UIViewContentMode = .ScaleAspectFit) -> UIImage? {
        switch algo {
        case .UI:
            UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
            self.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage
        case .CG:
            let cgImage = self.CGImage
            let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
            let bytesPerRow = CGImageGetBytesPerRow(cgImage)
            let colorSpace = CGImageGetColorSpace(cgImage)
            let bitmapInfo = CGImageGetBitmapInfo(cgImage)
            
            let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
            
            CGContextSetInterpolationQuality(context, .High)
            
            CGContextDrawImage(context, CGRect(origin: CGPointZero, size: size), cgImage)
            
            return CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }

        case .CI:
            let image = UIKit.CIImage(CGImage:self.CGImage!)
            
            let filter = CIFilter(name: "CILanczosScaleTransform")!
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(size.width/self.size.width, forKey: kCIInputScaleKey)
            let outputImage = filter.valueForKey(kCIOutputImageKey) as! UIKit.CIImage
            
            let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
            let resizedImage = UIImage(CGImage: context.createCGImage(outputImage, fromRect: outputImage.extent))
            return resizedImage
        case .VI:
            let cgImage = self.CGImage!
            
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
            let destWidth = Int(size.width)
            let destHeight = Int(size.height)
            let bytesPerPixel = CGImageGetBitsPerPixel(self.CGImage) / 8
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
    }
}