//
//  AppTheming.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import PhunwareTheming
import PhunwareMapping

extension UIColor {
    
    enum Palette {
        static let primary = UIColor(named: "Primary")!
        static let secondary = UIColor(named: "Secondary")!
        static let primaryVariant = UIColor(named: "PrimaryVariant")!
        static let secondaryVariant = UIColor(named: "SecondaryVariant")!
        static let background = UIColor(named: "Background")!
        static let surface = UIColor(named: "Surface")!
        static let onPrimary = UIColor(named: "OnPrimary")!
        static let onSecondary = UIColor(named: "OnSecondary")!
        static let onBackground = UIColor(named: "OnBackground")!
        static let onSurface = UIColor(named: "OnSurface")!
        static let error = UIColor(named: "Error")!
        static let onError = UIColor(named: "OnError")!
    }
}

extension MapThemeConfigurator {
    
    /// This is the starting point where theming can be configured on the mapping module.
    /// The semantic colors from the above `UIColor` extension are defined in the Assets.xcassets
    /// as part of the template project's bundle. It's recommended to update the colors in the assets catalog
    /// when configuring the color palette.
    static let current: MapThemeConfigurator = {
        MapThemeConfigurator(
            colors: ColorPalette(
                primary: UIColor.Palette.primary,
                secondary: UIColor.Palette.secondary,
                primaryVariant: UIColor.Palette.primaryVariant,
                secondaryVariant: UIColor.Palette.secondaryVariant,
                background: UIColor.Palette.background,
                surface: UIColor.Palette.surface,
                onPrimary: UIColor.Palette.onPrimary,
                onSecondary: UIColor.Palette.onSecondary,
                onBackground: UIColor.Palette.onBackground,
                onSurface: UIColor.Palette.onSurface,
                error: UIColor.Palette.error,
                onError: UIColor.Palette.onError
            ),
            texts: TextStyles(
                headline1: UIFont.boldSystemFont(ofSize: 28),
                headline2: UIFont.boldSystemFont(ofSize: 18),
                headline3: UIFont.systemFont(ofSize: 16),
                subtitle1: UIFont.boldSystemFont(ofSize: 16),
                subtitle2: UIFont.boldSystemFont(ofSize: 14),
                body1: UIFont.systemFont(ofSize: 14),
                body2: UIFont.systemFont(ofSize: 14),
                overline: UIFont.systemFont(ofSize: 12),
                caption: UIFont.boldSystemFont(ofSize: 12),
                button: UIFont.boldSystemFont(ofSize: 14)
            )
        )
    }()
}
