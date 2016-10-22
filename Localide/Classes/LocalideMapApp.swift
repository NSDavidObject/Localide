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
    case appleMaps = 10
    case citymapper = 20
    case googleMaps = 30
    case navigon = 40
    case transitApp = 50
    case waze = 60
    case yandexNavigator = 70

    public var appName: String {
        switch self {
        case .appleMaps:
            return "Apple Maps"
        case .citymapper:
            return "Citymapper"
        case .googleMaps:
            return "Google Maps"
        case .navigon:
            return "Navigon"
        case .transitApp:
            return "Transit App"
        case .waze:
            return "Waze"
        case .yandexNavigator:
            return "Yandex Navigator"
        }
    }

    internal static let AllMapApps: [LocalideMapApp] = [appleMaps, citymapper, googleMaps, navigon, transitApp, waze, yandexNavigator]
}

// MARK: - Public Helpers
public extension LocalideMapApp {
    /**
     Checks whether it is possible to launch the app. (Installed & Added to QuerySchemes)
     - returns: Whether it is possible to launch the app.
     */
    public func canOpenApp() -> Bool {
        guard let url = URL(string: LocalideMapApp.prefixes[self]!) else { return false }
        return LocalideMapApp.canOpenUrl(url)
    }
    /**
     Launch app
     - returns: Whether the launch of the application was successfull
     */
    public func launchApp() -> Bool {
        return LocalideMapApp.launchAppWithUrlString(LocalideMapApp.urlFormats[self]!)
    }
    /**
     Launch app with directions to location
     - parameter location: Latitude & Longitude of the directions's TO location
     - returns: Whether the launch of the application was successfull
     */
    @discardableResult public func launchAppWithDirections(toLocation location: CLLocationCoordinate2D) -> Bool {
        return LocalideMapApp.launchAppWithUrlString(urlStringForDirections(toLocation: location))
    }
}

// MARK: - Private Helpers
private extension LocalideMapApp {
    func urlStringForDirections(toLocation location: CLLocationCoordinate2D) -> String {
        return String(format: LocalideMapApp.urlFormats[self]!, arguments: [location.latitude, location.longitude])
    }
}

// MARK: - Private Static Helpers
private extension LocalideMapApp {

    static let prefixes: [LocalideMapApp: String] = [
        LocalideMapApp.appleMaps : "http://maps.apple.com/",
        LocalideMapApp.citymapper : "citymapper://",
        LocalideMapApp.googleMaps : "comgooglemaps://",
        LocalideMapApp.navigon : "navigon://",
        LocalideMapApp.transitApp : "transit://",
        LocalideMapApp.waze : "waze://",
        LocalideMapApp.yandexNavigator : "yandexnavi://"
    ]

    static let urlFormats: [LocalideMapApp: String] = [
        LocalideMapApp.appleMaps : "http://maps.apple.com/?daddr=%f,%f",
        LocalideMapApp.citymapper : "citymapper://endcoord=%f,%f",
        LocalideMapApp.googleMaps : "comgooglemaps://?daddr=%f,%f",
        LocalideMapApp.navigon : "navigon://coordinate/Destination/%f/%f",
        LocalideMapApp.transitApp : "transit://routes?q=%f,%f",
        LocalideMapApp.waze : "waze://?ll=%f,%f",
        LocalideMapApp.yandexNavigator : "yandexnavi://build_route_on_map?lat_to=%f&lon_to=%f"
    ]

    static func canOpenUrl(_ url: URL) -> Bool {
        return Localide.sharedManager.applicationProtocol.canOpenURL(url)
    }

    static func launchAppWithUrlString(_ urlString: String) -> Bool {
        guard let launchUrl = URL(string: urlString) , canOpenUrl(launchUrl) else { return false }
        return Localide.sharedManager.applicationProtocol.openURL(launchUrl)
    }
}
