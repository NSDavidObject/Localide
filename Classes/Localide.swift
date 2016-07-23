//
//  Localide.swift
//  Localide
//
//  Created by David Elsonbaty on 5/28/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit
import CoreLocation

public typealias LocalideUsageCompletion = (usedApp: LocalideMapApp, fromMemory: Bool, openedLinkSuccessfully: Bool) -> Void

internal protocol UIApplicationProtocol {
    func openURL(url: NSURL) -> Bool
    func canOpenURL(url: NSURL) -> Bool
}

extension UIApplication: UIApplicationProtocol {}

public final class Localide {

    public static let sharedManager: Localide = Localide()
    internal var applicationProtocol: UIApplicationProtocol = UIApplication.sharedApplication()

    // Unavailable initializer, use sharedManager.
    private init() {

    }

    /**
     Currently available map apps to launch. It includes:
     - Apple Maps
     - Installed 3rd party apps which are supported by Localide and included in the QuerySchemes
    */
    public lazy var availableMapApps: [LocalideMapApp] = Localide.private_availableMapApps()

    /**
     Reset the previously set user's map app preference
     */
    public func resetUserPreferences() {
        NSUserDefaults.resetMapAppPreferences()
    }

    /**
     Launch Apple Maps with directions to location
     - parameter location: Latitude & Longitude of the directions's TO location
     - returns: Whether the launch of the application was successfull
     */
    public func launchNativeAppleMapsAppForDirections(toLocation location: CLLocationCoordinate2D) -> Bool {
        return LocalideMapApp.AppleMaps.launchAppWithDirections(toLocation: location)
    }

    /**
     Prompt user for their preferred maps app, and launch it with directions to location
     - parameter location: Latitude & Longitude of the direction's to location
     - parameter rememberPreference: Whether to remember the user's preference for future uses or not. (note: preference is reset whenever the list of available apps change. ex. user installs a new map app.)
     - parameter usingASubsetOfApps: Handpicked subset of apps to use, use this parameter if you'd like to exclude some apps. (note: If none of which are available, Apple Maps will be fell back on.)
     - parameter completion: Called after attempting to launch app whether it being from previous preference or currently selected preference.
     */
    public func promptForDirections(toLocation location: CLLocationCoordinate2D, rememberPreference remember: Bool = false, usingASubsetOfApps apps: [LocalideMapApp]? = nil, onCompletion completion: LocalideUsageCompletion?) {
        
        var appChoices = self.availableMapApps
        if let apps = apps {
            appChoices = apps.filter({ self.availableMapApps.contains($0) })
            if appChoices.count == 0 {
                appChoices = [.AppleMaps]
            }
        }

        guard !remember || !NSUserDefaults.didSetPrefferedMapApp(fromChoices: appChoices) else {
            let preferredMapApp = NSUserDefaults.preferredMapApp(fromChoices: appChoices)!
            self.private_launchApp(preferredMapApp, withDirectionsToLocation: location, fromMemory: true, completion: completion)
            return
        }

        self.private_discoverUserPreferenceOfMapApps("Navigation", message: "Which app would you like to use for directions?", apps: appChoices) { app in
            if remember {
                NSUserDefaults.setPreferredMapApp(app, fromMapAppChoices: appChoices)
            }
            self.private_launchApp(app, withDirectionsToLocation: location, fromMemory: false, completion: completion)
        }
    }
}

// MARK: - Private Helpers
extension Localide {

    private class func private_availableMapApps() -> [LocalideMapApp] {
        return LocalideMapApp.AllMapApps.flatMap({ mapApp in
            return mapApp.canOpenApp() ? mapApp : nil
        })
    }

    private func private_launchApp(app: LocalideMapApp, withDirectionsToLocation location: CLLocationCoordinate2D, fromMemory: Bool, completion: LocalideUsageCompletion?) {
        let didLaunchMapApp = app.launchAppWithDirections(toLocation: location)
        completion?(usedApp: app, fromMemory: fromMemory, openedLinkSuccessfully: didLaunchMapApp)
    }

    private func private_discoverUserPreferenceOfMapApps(title: String, message: String, apps: [LocalideMapApp], completion: LocalideMapApp -> Void) {
        guard apps.count > 1 else {
            if let app = apps.first {
                completion(app)
            }
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.ActionSheet)

        for app in apps {
            let alertAction = UIAlertAction.localideAction(withTitle: app.appName, style: UIAlertActionStyle.Default, handler: { _ in completion(app) })
            alertAction.mockMapApp = app
            alertController.addAction(alertAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)

        UIApplication.topViewController()?.presentViewController(alertController, animated: true, completion: nil)
    }
}