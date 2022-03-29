//
//  Theme.swift
//  EraseMind
//
//  Created by Jimin Song
//

import UIKit

class Theme {
    static let pink = UIColor(hex: "EB9597")!
    static let black = UIColor(hex: "000000")!
    static let lightBrown = UIColor(hex: "5F3838")!
    static let pinkishWhite = UIColor(hex: "F9DFE0")!
    static let cardBackground = UIColor(hex: "FFB4B5")!
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat
        let start = hex.hasPrefix("#") ? hex.index(hex.startIndex, offsetBy: 1) : hex.startIndex
            let hexColor = String(hex[start...])
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: 1)
                return
            }
        }
        return nil
    }
}

class Font {
    class func font(size: CGFloat) -> UIFont {
        return UIFont(name: "FrankfurterStd", size: ceil(size))!
    }
    
    class func adjustedAttributedString(text: String, font: UIFont) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        let attributedText = NSAttributedString(string: text, attributes: [.font: font, .kern: -0.5, .paragraphStyle: paragraphStyle])
        return attributedText
    }
}
