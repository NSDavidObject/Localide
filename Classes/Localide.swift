//
//  Localide.swift
//  Localide
//
//  Created by David Elsonbaty on 5/28/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit
import CoreLocation

public typealias LocalideUsageCompletion = (_ usedApp: LocalideMapApp, _ fromMemory: Bool, _ openedLinkSuccessfully: Bool) -> Void

internal protocol UIApplicationProtocol {
    func openURL(_ url: URL) -> Bool
    func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: UIApplicationProtocol {}

public final class Localide {

    public static let sharedManager: Localide = Localide()
    internal var applicationProtocol: UIApplicationProtocol = UIApplication.shared

    // Unavailable initializer, use sharedManager.
    fileprivate init() {

    }

    /**
     Currently available map apps to launch. It includes:
     - Apple Maps
     - Installed 3rd party apps which are supported by Localide and included in the QuerySchemes
    */
    public lazy var availableMapApps: [LocalideMapApp] = Localide.installedMapApps()

    /**
     Reset the previously set user's map app preference
     */
    public func resetUserPreferences() {
        UserDefaults.resetMapAppPreferences()
    }

    /**
     Launch Apple Maps with directions to location
     - parameter location: Latitude & Longitude of the directions's TO location
     - returns: Whether the launch of the application was successfull
     */
    public func launchNativeAppleMapsAppForDirections(toLocation location: CLLocationCoordinate2D) -> Bool {
        return LocalideMapApp.appleMaps.launchAppWithDirections(toLocation: location)
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
                appChoices = [.appleMaps]
            }
        }

        guard !remember || !UserDefaults.didSetPrefferedMapApp(fromChoices: appChoices) else {
            let preferredMapApp = UserDefaults.preferredMapApp(fromChoices: appChoices)!
            self.launchApp(preferredMapApp, withDirectionsToLocation: location, fromMemory: true, completion: completion)
            return
        }

        self.discoverUserPreferenceOfMapApps("Navigation", message: "Which app would you like to use for directions?", apps: appChoices) { app in
            if remember {
                UserDefaults.setPreferredMapApp(app, fromMapAppChoices: appChoices)
            }
            self.launchApp(app, withDirectionsToLocation: location, fromMemory: false, completion: completion)
        }
    }
}

// MARK: - Private Helpers
extension Localide {

    fileprivate class func installedMapApps() -> [LocalideMapApp] {
        return LocalideMapApp.AllMapApps.flatMap({ mapApp in
            return mapApp.canOpenApp() ? mapApp : nil
        })
    }

    fileprivate func launchApp(_ app: LocalideMapApp, withDirectionsToLocation location: CLLocationCoordinate2D, fromMemory: Bool, completion: LocalideUsageCompletion?) {
        let didLaunchMapApp = app.launchAppWithDirections(toLocation: location)
        completion?(app, fromMemory, didLaunchMapApp)
    }

    fileprivate func discoverUserPreferenceOfMapApps(_ title: String, message: String, apps: [LocalideMapApp], completion: @escaping (LocalideMapApp) -> Void) {
        guard apps.count > 1 else {
            if let app = apps.first {
                completion(app)
            }
            return
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)

        for app in apps {
            let alertAction = UIAlertAction.localideAction(withTitle: app.appName, style: UIAlertActionStyle.default, handler: { _ in completion(app) })
            alertAction.mockMapApp = app
            alertController.addAction(alertAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)

        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
