//
//  UIFont+App.swift
//  PhunwareMapping
//
//  Created by Henry Peng on 2/9/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import UIKit

// MARK: - Supported Fonts
extension UIFont {

    enum OpenSans: String, RegisterableFontFamily {
        case regular = "OpenSans-Regular"
        case semiBold = "OpenSans-SemiBold"
        case bold = "OpenSans-Bold"
        case extraBold = "OpenSans-ExtraBold"

        static var isRegistered = false
    }
}

// MARK: - RegisterableFontFamily

/// Convenience protocol to capture common code relating to registering
/// and using font families that are represented by enums.
protocol RegisterableFontFamily: CaseIterable, RawRepresentable {
    var rawValue: String { get }

    static var isRegistered: Bool { get set }

    static func registerFonts()
}

extension RegisterableFontFamily {

    static func registerFonts() {
        guard isRegistered == false else {
            return
        }
        
        let fontURLs = allCases.compactMap { Bundle.main.url(forResource: $0.rawValue, withExtension: "ttf") }
        CTFontManagerUnregisterFontURLs(fontURLs as CFArray, .process, nil)
        CTFontManagerRegisterFontURLs(fontURLs as CFArray, .process, true, nil)
        
        isRegistered = true
    }

    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
