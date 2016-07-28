//
//  LocalideMapApp.swift
//  Localide
//
//  Created by David Elsonbaty on 5/28/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit
import CoreLocation

public enum LocalideMapApp: Int {
    case AppleMaps = 10
    case Citymapper = 20
    case GoogleMaps = 30
    case Navigon = 40
    case TransitApp = 50
    case Waze = 60
    case YandexNavigator = 70

    public var appName: String {
        switch self {
        case AppleMaps:
            return "Apple Maps"
        case Citymapper:
            return "Citymapper"
        case GoogleMaps:
            return "Google Maps"
        case Navigon:
            return "Navigon"
        case TransitApp:
            return "Transit App"
        case Waze:
            return "Waze"
        case YandexNavigator:
            return "Yandex Navigator"
        }
    }

    internal static let AllMapApps: [LocalideMapApp] = [AppleMaps, Citymapper, GoogleMaps, Navigon, TransitApp, Waze, YandexNavigator]
}

// MARK: - Public Helpers
public extension LocalideMapApp {
    /**
     Checks whether it is possible to launch the app. (Installed & Added to QuerySchemes)
     - returns: Whether it is possible to launch the app.
     */
    public func canOpenApp() -> Bool {
        guard let url = NSURL(string: LocalideMapApp.prefixes[self]!) else { return false }
        return LocalideMapApp.private_canOpenUrl(url)
    }
    /**
     Launch app
     - returns: Whether the launch of the application was successfull
     */
    public func launchApp() -> Bool {
        return LocalideMapApp.private_launchAppWithUrlString(LocalideMapApp.urlFormats[self]!)
    }
    /**
     Launch app with directions to location
     - parameter location: Latitude & Longitude of the directions's TO location
     - returns: Whether the launch of the application was successfull
     */
    public func launchAppWithDirections(toLocation location: CLLocationCoordinate2D) -> Bool {
        return LocalideMapApp.private_launchAppWithUrlString(self.private_urlStringForDirections(location))
    }
}

// MARK: - Private Helpers
private extension LocalideMapApp {
    private func private_urlStringForDirections(location: CLLocationCoordinate2D) -> String {
        return String(format: LocalideMapApp.urlFormats[self]!, arguments: [location.latitude, location.longitude])
    }
}

// MARK: - Private Static Helpers
private extension LocalideMapApp {

    private static let prefixes: [LocalideMapApp: String] = [
        LocalideMapApp.AppleMaps : "http://maps.apple.com/",
        LocalideMapApp.Citymapper : "citymapper://",
        LocalideMapApp.GoogleMaps : "comgooglemaps://",
        LocalideMapApp.Navigon : "navigon://",
        LocalideMapApp.TransitApp : "transit://",
        LocalideMapApp.Waze : "waze://",
        LocalideMapApp.YandexNavigator : "yandexnavi://"
    ]

    private static let urlFormats: [LocalideMapApp: String] = [
        LocalideMapApp.AppleMaps : "http://maps.apple.com/?daddr=%f,%f",
        LocalideMapApp.Citymapper : "citymapper://endcoord=%f,%f",
        LocalideMapApp.GoogleMaps : "comgooglemaps://?daddr=%f,%f",
        LocalideMapApp.Navigon : "navigon://coordinate/Destination/%f/%f",
        LocalideMapApp.TransitApp : "transit://routes?q=%f,%f",
        LocalideMapApp.Waze : "waze://?ll=%f,%f",
        LocalideMapApp.YandexNavigator : "yandexnavi://build_route_on_map?lat_to=%f&lon_to=%f"
    ]

    private static func private_canOpenUrl(url: NSURL) -> Bool {
        return Localide.sharedManager.applicationProtocol.canOpenURL(url)
    }
    private static func private_launchAppWithUrlString(urlString: String) -> Bool {
        guard let launchUrl = NSURL(string: urlString) where self.private_canOpenUrl(launchUrl) else { return false }
        return Localide.sharedManager.applicationProtocol.openURL(launchUrl)
    }
}
