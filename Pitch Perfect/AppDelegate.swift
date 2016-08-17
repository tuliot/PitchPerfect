//
//  AppDelegate.swift
//  Pitch Perfect
//
//  Created by Tulio Troncoso on 7/9/16.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tripleTapGestureRecognizer: UITapGestureRecognizer?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        let theme = ThemeManager.currentTheme()
        ThemeManager.applyTheme(theme)
        attachThemePickerRecognizer()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        if let tripleTap = tripleTapGestureRecognizer {
            self.window?.removeGestureRecognizer(tripleTap)
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

        attachThemePickerRecognizer()
    }

    /**
     Creates a UITapGestureRecognizer and attaches it to the main window. This recognizer will recognize three taps and will bring up the theme picker
     */
    func attachThemePickerRecognizer() {
        tripleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showThemePicker))

        if let tripleTap = tripleTapGestureRecognizer {
            tripleTap.numberOfTapsRequired = 3
            tripleTap.numberOfTouchesRequired = 2
            self.window?.addGestureRecognizer(tripleTap)
            print("Added tripletap")
        }
    }

    func showThemePicker() {
        print("Should show theme picker")

        let alertController = UIAlertController(title: "Change Theme", message: "Please choose one of our awesome themes", preferredStyle: .ActionSheet)

        let availableThemes = Theme.availableThemes()

        availableThemes.forEach { (theme) in
            let action = UIAlertAction(title: theme.rawValue, style: .Default, handler: { _ in
                ThemeManager.applyTheme(theme)

                UIApplication.sharedApplication().windows.forEach({ (window) in
                    window.subviews.forEach({ (view) in
                        view.removeFromSuperview()
                        window.addSubview(view)
                    })
                })

                // Used to communicate to the app that the theme has changed
//                NSNotificationCenter.defaultCenter().postNotificationName("Theme Change", object: nil)
            })

            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))

        alertController.modalInPopover = true

        window?.rootViewController?.presentViewController(alertController, animated: true, completion: {
            print("Changed theme")
        })
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

