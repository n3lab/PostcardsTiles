//
//  UIColor+Extension.swift
//  PostcardsTiles
//
//  Created by n3deep on 04.07.2021.
//

import Foundation
import UIKit

extension UIColor {

    static let navbarBackgroundColor = UIColor(red: 103.0/255.0, green: 58.0/255.0, blue: 183.0/255.0, alpha: 1.0)
    static let navbarFontColor = UIColor.white
    
    static func random() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
