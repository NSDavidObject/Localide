//
//  LocalideTests.swift
//  LocalideTests
//
//  Created by David Elsonbaty on 5/30/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Localide

class LocalideTests: XCTestCase {

    fileprivate let applicationProtocolTest = UIApplicationProtocolTest()
    let locationZero = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Localide.sharedManager.applicationProtocol = applicationProtocolTest
    }

    func testAvailableMapApps() {
        XCTAssertEqual(Localide.sharedManager.availableMapApps, LocalideMapApp.AllMapApps)
    }

    func testLaunchNativeAppleMapsApp() {

        let location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        XCTAssertTrue(Localide.sharedManager.launchNativeAppleMapsAppForDirections(toLocation: location))
        XCTAssertEqual(applicationProtocolTest.lastOpenedUrl, testDidLaunchApplication(.appleMaps))
    }

    func testPromptForDirectionsNoOptions() {

        Localide.sharedManager.promptForDirections(toLocation: locationZero, usingASubsetOfApps: []) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(LocalideMapApp.appleMaps, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }



        XCTAssertNil(currentAlertActions())
        XCTAssertEqual(applicationProtocolTest.lastOpenedUrl, testDidLaunchApplication(.appleMaps))
    }

    func testPromptForDirectionsOneOption() {

        Localide.sharedManager.promptForDirections(toLocation: locationZero, usingASubsetOfApps: [.googleMaps]) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(LocalideMapApp.googleMaps, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        XCTAssertNil(currentAlertActions())
        XCTAssertEqual(applicationProtocolTest.lastOpenedUrl, testDidLaunchApplication(.googleMaps))
    }

    func testPromptForDirectionsMutipleOptions() {

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        let actions = currentAlertActions()!
        for action in actions {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        resetViewHierarchy()
    }

    func testPromptForDirectionsWithMemory() {
        Localide.sharedManager.resetUserPreferences()

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero, rememberPreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        let actions = currentAlertActions()
        XCTAssertNotNil(actions)
        for action in actions! {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        resetViewHierarchy()

        let appFromMemory: LocalideMapApp = actions!.last!.mockMapApp!
        Localide.sharedManager.promptForDirections(toLocation: locationZero, rememberPreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(appFromMemory, usedApp)
            XCTAssertTrue(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        XCTAssertNil(currentAlertActions())
        XCTAssertEqual(applicationProtocolTest.lastOpenedUrl, testDidLaunchApplication(appFromMemory))
    }

    func testPromptForDirectionsWithMemoryAndChangeOfAvailability() {
        Localide.sharedManager.resetUserPreferences()

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero, rememberPreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        let actions = currentAlertActions()
        XCTAssertNotNil(actions)
        for action in actions! {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        resetViewHierarchy()

        Localide.sharedManager.promptForDirections(toLocation: locationZero, rememberPreference: true, usingASubsetOfApps: [.googleMaps, .waze]) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.testDidLaunchApplication(usedApp))
        }

        let actions2 = currentAlertActions()!
        for action in actions2 {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        XCTAssertTrue(actions2.count == 2)
    }

    // MARK: Private Helpers
    func resetViewHierarchy() {
        UIApplication.shared.keyWindow?.rootViewController = UIViewController()
    }
    func currentAlertActions() -> [LocalideAlertAction]? {
        guard let alertController = UIApplication.topViewController() as? UIAlertController else { return nil }
        let actions = alertController.actions
        let localideActions = actions.filter { alertAction -> Bool in
            return (alertAction as? LocalideAlertAction) != nil
        }
        return localideActions as? [LocalideAlertAction]
    }
    func testDidLaunchApplication(_ app: LocalideMapApp, toLocation location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) -> String {
        return String(format: LocalideMapAppTestHelper.urlFormats[app]!, arguments: [location.latitude, location.longitude])
    }
}

// MARK: - Private Helpers
private class LocalideMapAppTestHelper {
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
}

private class UIApplicationProtocolTest: UIApplicationProtocol {
    var lastOpenedUrl: String = ""
    func canOpenURL(_ url: URL) -> Bool {
        return true
    }
    func openURL(_ url: URL) -> Bool {
        lastOpenedUrl = url.absoluteString
        return canOpenURL(url)
    }
}
