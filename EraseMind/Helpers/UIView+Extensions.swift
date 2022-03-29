//
//  UIView+Extensions.swift
//  EraseMind
//
//  Created by Created by Jimin Song
//

import UIKit

extension UIView {
    var safeLayoutGuideTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeLayoutGuideBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return topAnchor
    }
}

extension UIScreen {
    class var isSmallPhone: Bool {
        return UIScreen.main.bounds.width <= 320
    }
}

