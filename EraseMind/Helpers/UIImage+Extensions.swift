//
//  UIImage+Extensions.swift
//  EraseMind
//
//  Created by Created by Jimin Song
//

import UIKit

extension UIImage {
    func imageWithOverlayColor(color: UIColor?) -> UIImage? {
        guard let color = color else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.sourceIn)
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func image(_ color: UIColor, size: CGSize = .zero) -> UIImage {
        var s = size
        s.width = max(s.width, 1)
        s.height = max(s.height, 1)
        
        UIGraphicsBeginImageContextWithOptions(s, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: s))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        return image
    }
}

