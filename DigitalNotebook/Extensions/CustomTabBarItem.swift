//
//  CustomTabBarItem.swift
//  DigitalNotebook
//
//  Created by Developer on 23/05/25.
//

import UIKit

extension UITabBarItem {
    static func applyCustomTitleColors(selected: UIColor, unselected: UIColor) {
        let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: selected]
        let unselectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: unselected]
        
        UITabBarItem.appearance().setTitleTextAttributes(unselectedAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
