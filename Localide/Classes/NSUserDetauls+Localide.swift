//
//  NSUserDetauls+Localide.swift
//  Localide
//
//  Created by David Elsonbaty on 5/29/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import Foundation

internal extension UserDefaults {

    fileprivate static let PreferredMapAppKey = "Localide.Preferred-Map-App"
    fileprivate static let MapAppChoicesKey = "Localide.Installed-Map-Apps"

    internal class func didSetPrefferedMapApp(fromChoices choices: [LocalideMapApp]) -> Bool {
        return (self.preferredMapApp(fromChoices: choices) != nil)
    }

    internal class func preferredMapApp(fromChoices choices: [LocalideMapApp]) -> LocalideMapApp? {
        // Ensure a preferred map app is set
        guard let preferredMapAppIndex = UserDefaults.standard.object(forKey: UserDefaults.PreferredMapAppKey) as? Int else { return nil }
        // Ensure there were no changes to the previous state of installed apps.
        guard previousMapAppChoices() == choices else { return nil }

        return LocalideMapApp(rawValue: preferredMapAppIndex)
    }

    internal class func setPreferredMapApp(_ app: LocalideMapApp, fromMapAppChoices choices: [LocalideMapApp]) {
        // Save the preferred map app
        UserDefaults.standard.set(app.rawValue, forKey: UserDefaults.PreferredMapAppKey)
        // Save the current state of map app choices
        UserDefaults.standard.set(choices.map({ $0.rawValue }), forKey: UserDefaults.MapAppChoicesKey)
    }

    internal class func resetMapAppPreferences() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.PreferredMapAppKey)
        UserDefaults.standard.removeObject(forKey: UserDefaults.MapAppChoicesKey)
    }

    fileprivate class func previousMapAppChoices() -> [LocalideMapApp] {
        return (UserDefaults.standard.object(forKey: UserDefaults.MapAppChoicesKey) as! [Int]).map({ return LocalideMapApp(rawValue: $0)! })
    }
}
