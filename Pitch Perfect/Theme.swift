//
//  Style.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/30/16.
//
//  Shout out to Essan Parto's article on RayWenderlich.com https://www.raywenderlich.com/108766/uiappearance-tutorial

import UIKit
import Foundation

/// Theme of the application. Colors are stored here
enum Theme {
    case Default

    /// "Pop" color of the application
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.8977, green:0.556, blue:0.2651, alpha:1.0)
        }
    }

    /// Style of the Navigation Bar
    var navBarStyle: UIBarStyle {
        switch self {
        case .Default:
            return .Black
        }
    }

    /// Color of the nav bar
    var navBarColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.1511, green:0.1739, blue:0.2079, alpha:1)
        }
    }

    /// Color of the background of the top-most view
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.1511, green:0.1739, blue:0.2079, alpha:0.1)
        }
    }

    /// Color of the Modulator Buttons
    var modulatorButtonColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red:0.8977, green:0.556, blue:0.2651, alpha:1.0)
        }
    }

    /// Color of the text inside the modulator buttons
    var modulatorButtonTextColor: UIColor {
        switch self {
        case .Default:
            return UIColor.whiteColor()
        }
    }

}

/**
 *  Manages interactions with the Theme of the application.
 */
struct ThemeManager {
    let selectedTheme = "Default"

    /**
     Returns the current theme. As of now, it only returns the default theme

     - returns: Current Theme
     */
    static func currentTheme() -> Theme {
        //TODO: Make this use the stored theme in NSUserDefaults, also find a way to store to NSUserDefaults :)
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

    }
}