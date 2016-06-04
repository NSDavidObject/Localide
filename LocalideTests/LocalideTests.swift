//
//  LocalideTests.swift
//  LocalideTests
//
//  Created by David Elsonbaty on 5/30/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import XCTest
@testable import Localide

class LocalideTests: XCTestCase {

    private let applicationProtocolTest = UIApplicationProtocolTest()
    let locationZero = LocalideGeoLocation(latitude: 0.0, longitude: 0.0)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Localide.sharedManager.applicationProtocol = applicationProtocolTest
    }

    func testAvailableMapApps() {
        XCTAssertEqual(Localide.sharedManager.availableMapApps, LocalideMapApp.AllMapApps)
    }

    func testLaunchNativeAppleMapsApp() {

        let location = LocalideGeoLocation(latitude: 0.0, longitude: 0.0)
        XCTAssertTrue(Localide.sharedManager.launchNativeAppleMapsAppForDirections(toLocation: location))
        XCTAssertEqual(applicationProtocolTest.lastOpenedUrl, private_testDidLaunchApplication(.AppleMaps))
    }

    func testPromptForDirectionsNoOptions() {

        Localide.sharedManager.promptForDirections(toLocation: locationZero, usingASubsetOfApps: []) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(LocalideMapApp.AppleMaps, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        XCTAssertNil(private_currentAlertActions())
        XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(.AppleMaps))
    }

    func testPromptForDirectionsOneOption() {

        Localide.sharedManager.promptForDirections(toLocation: locationZero, usingASubsetOfApps: [.GoogleMaps]) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(LocalideMapApp.GoogleMaps, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        XCTAssertNil(private_currentAlertActions())
        XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(.GoogleMaps))
    }

    func testPromptForDirectionsMutipleOptions() {

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        let actions = private_currentAlertActions()!
        for action in actions {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        private_resetViewHierarchy()
    }

    func testPromptForDirectionsWithMemory() {
        Localide.sharedManager.resetUserPreferences()

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero, remembePreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        let actions = private_currentAlertActions()
        XCTAssertNotNil(actions)
        for action in actions! {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        private_resetViewHierarchy()

        let appFromMemory: LocalideMapApp = actions!.last!.mockMapApp!
        Localide.sharedManager.promptForDirections(toLocation: locationZero, remembePreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(appFromMemory, usedApp)
            XCTAssertTrue(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        XCTAssertNil(private_currentAlertActions())
        XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(appFromMemory))
    }

    func testPromptForDirectionsWithMemoryAndChangeOfAvailability() {
        Localide.sharedManager.resetUserPreferences()

        var lastSelectedApp: LocalideMapApp?
        Localide.sharedManager.promptForDirections(toLocation: locationZero, remembePreference: true) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        let actions = private_currentAlertActions()
        XCTAssertNotNil(actions)
        for action in actions! {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        private_resetViewHierarchy()

        Localide.sharedManager.promptForDirections(toLocation: locationZero, remembePreference: true, usingASubsetOfApps: [.GoogleMaps, .Waze]) { (usedApp, fromMemory, openedLinkSuccessfully) in
            XCTAssertEqual(lastSelectedApp, usedApp)
            XCTAssertFalse(fromMemory)
            XCTAssertTrue(openedLinkSuccessfully)
            XCTAssertEqual(self.applicationProtocolTest.lastOpenedUrl, self.private_testDidLaunchApplication(usedApp))
        }

        let actions2 = private_currentAlertActions()!
        for action in actions2 {
            lastSelectedApp = action.mockMapApp
            action.mockHandler!(action)
        }

        XCTAssertTrue(actions2.count == 2)
    }

    // MARK: Private Helpers
    func private_resetViewHierarchy() {
        UIApplication.sharedApplication().keyWindow?.rootViewController = UIViewController()
    }
    func private_currentAlertActions() -> [LocalideAlertAction]? {
        guard let alertController = UIApplication.topViewController() as? UIAlertController else { return nil }
        let actions = alertController.actions
        let localideActions = actions.filter { alertAction -> Bool in
            return (alertAction as? LocalideAlertAction) != nil
        }
        return localideActions as? [LocalideAlertAction]
    }
    func private_testDidLaunchApplication(app: LocalideMapApp, toLocation location: LocalideGeoLocation = (0,0)) -> String {
        return String(format: LocalideMapAppTestHelper.urlFormats[app]!, arguments: [location.latitude, location.longitude])
    }
}

// MARK: - Private Helpers
private class LocalideMapAppTestHelper {
    static let prefixes: [LocalideMapApp: String] = [
        LocalideMapApp.AppleMaps : "http://maps.apple.com/",
        LocalideMapApp.Citymapper : "citymapper://",
        LocalideMapApp.GoogleMaps : "comgooglemaps://",
        LocalideMapApp.Navigon : "navigon://",
        LocalideMapApp.TransitApp : "transit://",
        LocalideMapApp.Waze : "waze://"
    ]
    static let urlFormats: [LocalideMapApp: String] = [
        LocalideMapApp.AppleMaps : "http://maps.apple.com/?daddr=%f,%f",
        LocalideMapApp.Citymapper : "citymapper://endcoord=%f,%f",
        LocalideMapApp.GoogleMaps : "comgooglemaps://?daddr=%f,%f",
        LocalideMapApp.Navigon : "navigon://coordinate/Destination/%f/%f",
        LocalideMapApp.TransitApp : "transit://routes?q=%f,%f",
        LocalideMapApp.Waze : "waze://?ll=%f,%f"
    ]
}

private class UIApplicationProtocolTest: UIApplicationProtocol {
    var lastOpenedUrl: String = ""
    func canOpenURL(url: NSURL) -> Bool {
        return true
    }
    func openURL(url: NSURL) -> Bool {
        lastOpenedUrl = url.absoluteString
        return canOpenURL(url)
    }
}

