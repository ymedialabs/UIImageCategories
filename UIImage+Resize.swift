import UIKit
import CoreImage

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
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledImage
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
            let image = CIImage(self.CGImage)
            
            let filter = CIFilter(name: "CILanczosScaleTransform")!
            filter.setValue(image, forKey: "inputImage")
            filter.setValue(0.5, forKey: "inputScale")
            filter.setValue(1.0, forKey: "inputAspectRatio")
            let outputImage = filter.valueForKey("outputImage") as! CIImage
            
            let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
            let scaledImage = UIImage(CGImage: self.context.createCGImage(outputImage, fromRect: outputImage.extent()))

        default:
            return nil
        }
    }
}