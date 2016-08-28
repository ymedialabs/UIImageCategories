import UIKit

extension UIImage {
    enum ImageType {
        case UI
        case CG
        case CI
        case VI
        
        func resize(UIImage:image, size:CGSize, mode:UIViewContentMode = .ScaleAspectFit) -> UIImage? {
            switch self {
            case UI:
                let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
                UIGraphicsBeginImageContextWithOptions(size, true, 0)
                image.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return scaledImage
            default:
                return nil
            }
        }
    }
}