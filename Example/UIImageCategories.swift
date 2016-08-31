import UIKit
import CoreImage
import Accelerate

extension UIImage {
    func resizeUI(size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
 
extension UIImage {
    func resizeCG(size:CGSize) -> UIImage? {
        let bitsPerComponent = CGImageGetBitsPerComponent(self.CGImage)
        let bytesPerRow = CGImageGetBytesPerRow(self.CGImage)
        let colorSpace = CGImageGetColorSpace(self.CGImage)
        let bitmapInfo = CGImageGetBitmapInfo(self.CGImage)
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        CGContextSetInterpolationQuality(context, .High)
        
        CGContextDrawImage(context, CGRect(origin: CGPoint.zero, size: size), self.CGImage)
        
        return CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }        
    }
}
 
extension UIImage {
    func resizeCI(size:CGSize) -> UIImage? {
        let scale = (Double)(size.width) / (Double)(self.size.width)
            let image = UIKit.CIImage(CGImage:self.CGImage!)
            
            let filter = CIFilter(name: "CILanczosScaleTransform")!
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(NSNumber(double:scale), forKey: kCIInputScaleKey)
            filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
            let outputImage = filter.valueForKey(kCIOutputImageKey) as! UIKit.CIImage
            
            let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
            let resizedImage = UIImage(CGImage: context.createCGImage(outputImage, fromRect: outputImage.extent))
            return resizedImage
    }
}
 
extension UIImage {
    func resizeVI(size:CGSize) -> UIImage? {
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