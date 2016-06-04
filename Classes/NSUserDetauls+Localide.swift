//
//  NSUserDetauls+Localide.swift
//  Localide
//
//  Created by David Elsonbaty on 5/29/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import Foundation

internal extension NSUserDefaults {

    private static let PreferredMapAppKey = "Localide.Preferred-Map-App"
    private static let MapAppChoicesKey = "Localide.Installed-Map-Apps"

    internal class func didSetPrefferedMapApp(fromChoices choices: [LocalideMapApp]) -> Bool {
        return (self.preferredMapApp(fromChoices: choices) != nil)
    }

    internal class func preferredMapApp(fromChoices choices: [LocalideMapApp]) -> LocalideMapApp? {
        // Ensure a preferred map app is set
        guard let preferredMapAppIndex = NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaults.PreferredMapAppKey) as? Int else { return nil }
        // Ensure there were no changes to the previous state of installed apps.
        guard self.private_previousMapAppChoices() == choices else { return nil }

        return LocalideMapApp(rawValue: preferredMapAppIndex)
    }

    internal class func setPreferredMapApp(app: LocalideMapApp, fromMapAppChoices choices: [LocalideMapApp]) {
        // Save the preferred map app
        NSUserDefaults.standardUserDefaults().setInteger(app.rawValue, forKey: NSUserDefaults.PreferredMapAppKey)
        // Save the current state of map app choices
        NSUserDefaults.standardUserDefaults().setObject(choices.map({ $0.rawValue }), forKey: NSUserDefaults.MapAppChoicesKey)
    }

    internal class func resetMapAppPreferences() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(NSUserDefaults.PreferredMapAppKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(NSUserDefaults.MapAppChoicesKey)
    }

    private class func private_previousMapAppChoices() -> [LocalideMapApp] {
        return (NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaults.MapAppChoicesKey) as! [Int]).map({ return LocalideMapApp(rawValue: $0)! })
    }
}
