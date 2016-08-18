//
//  Style.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/30/16.
//
//  Shout out to Essan Parto's article on RayWenderlich.com https://www.raywenderlich.com/108766/uiappearance-tutorial

import UIKit
import Foundation

let kNSUserDefaultsThemeKey = "theme"

/// Theme of the application. Colors are stored here
enum Theme: String {
    case Default = "Default"
    case Green = "Green"

    /// Returns an array of available themes
    static func availableThemes() -> [Theme] {
        return [.Default, .Green]
    }

    /// "Pop" color of the application
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.8977, green:0.556, blue:0.2651, alpha:1.0)
        case .Green:
            return UIColor(red:0.3381, green:0.8651, blue:0.4965, alpha:1.0)
        }
    }

    /// Style of the Navigation Bar
    var navBarStyle: UIBarStyle {
        switch self {
        case .Default:
            return .Black
        case .Green:
            return .Black
        }
    }

    /// Color of the nav bar
    var navBarColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.1511, green:0.1739, blue:0.2079, alpha:1)
        case .Green:
            return UIColor(red:0.1349, green:0.2714, blue:0.179, alpha:1.0)
        }
    }

    /// Color of the background of the top-most view
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.1511, green:0.1739, blue:0.2079, alpha:0.1)
        case .Green:
            return UIColor(red:0.1549, green:0.3699, blue:0.2373, alpha:0.1)
        }
    }

    /// Color of the Modulator Buttons
    var modulatorButtonColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.8977, green:0.556, blue:0.2651, alpha:1.0)
        case .Green:
            return UIColor(red:0.3381, green:0.8651, blue:0.4965, alpha:1.0)
        }
    }

    /// Color of the text inside the modulator buttons
    var modulatorButtonTextColor: UIColor {
        switch self {
        case .Default:
            return UIColor.whiteColor()
        case .Green:
            return UIColor.whiteColor()
        }
    }

}

/**
 *  Manages interactions with the Theme of the application.
 */
struct ThemeManager {

    /**
     Returns the current theme. As of now, it only returns the default theme

     - returns: Current Theme
     */
    static func currentTheme() -> Theme {
        //TODO: Make this use the stored theme in NSUserDefaults, also find a way to store to NSUserDefaults :)

        let defaults = NSUserDefaults.standardUserDefaults()

        if let savedThemeString = defaults.objectForKey(kNSUserDefaultsThemeKey) {

            if let savedTheme = Theme.init(rawValue: savedThemeString as! String) {
                return savedTheme
            }
        }

        // We couldn't get the theme from User Defaults, so set the theme to Default, and save
        saveTheme(.Default)
        return .Default
    }

    /**
     Applies a theme to the application

     - parameter theme: Theme that should be applied
     */
    static func applyTheme(theme: Theme) {

        //TODO: Store the theme to NSUserDefaults here

        // Apply tint color
        let sharedApplication = UIApplication.sharedApplication()
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        sharedApplication.delegate?.window??.backgroundColor = theme.backgroundColor

        // Apply nav bar color
        UINavigationBar.appearance().barStyle = theme.navBarStyle
        UINavigationBar.appearance().barTintColor = theme.navBarColor

        // Apply modulator button color
        ModulatorCollectionViewCell.appearance().backgroundColor = theme.modulatorButtonColor
        ModulatorCollectionViewCell.appearance().tintColor = theme.modulatorButtonTextColor
        UILabel.appearanceWhenContainedInInstancesOfClasses([ModulatorCollectionViewCell.self]).textColor = theme.modulatorButtonTextColor

        saveTheme(theme)
    }

    /**
     Saves theme to NSUserDefaults

     - parameter theme: Theme
     */
    static func saveTheme(theme: Theme) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(theme.rawValue, forKey: kNSUserDefaultsThemeKey)

    }
}