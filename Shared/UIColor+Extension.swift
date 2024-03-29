//
//  UIColor+Extension.swift
//  sense-ios
//
//  Created by Michal Šimík on 03.03.2022.
//

// swiftlint:disable identifier_name

import UIKit

typealias HexadecimalString = String

extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: HexadecimalString) {

        var hexProcessed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexProcessed = hexProcessed.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0

        var a: CGFloat = 1.0
        let length = hexProcessed.count

        guard Scanner(string: hexProcessed).scanHexInt32(&rgb) else {
            return nil
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var hexString: HexadecimalString? {
        return hexString()
    }

    // MARK: - From UIColor to Hex String

    func hexString(alpha: Bool = false) -> HexadecimalString? {

        // Safely unwrapping because components property is type [CGFloat]?
        // Also mage sure that it contains a minimum of 3 components
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        // if there is an alpha value extract it too
        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(r * 255),
                          lroundf(g * 255),
                          lroundf(b * 255),
                          lroundf(a * 255))
        }
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
