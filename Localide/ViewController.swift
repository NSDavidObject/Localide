//
//  ViewController.swift
//  Localide
//
//  Created by David Elsonbaty on 5/30/16.
//  Copyright © 2016 David Elsonbaty. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var promptSwitch: UISwitch!
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var appChoiceSegmentControl: UISegmentedControl!

    var switchOptions = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupGestureRecognizers()
        self.configureConfigurationControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView(withTapGesture:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = true
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }

    func didTapMapView(withTapGesture gesture: UITapGestureRecognizer) {
        let gestureLocation = gesture.locationInView(self.mapView)
        let gestureCoordinate = self.mapView.convertPoint(gestureLocation, toCoordinateFromView: self.mapView)
        self.handleLocalideAction(withCoordinate: gestureCoordinate)
    }

    func handleLocalideAction(withCoordinate coordinate: CLLocationCoordinate2D) {

        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if self.promptSwitch.on {

            let promptFunction = {
                Localide.sharedManager.promptForDirections(toLocation: location, rememberPreference: self.rememberSwitch.on, onCompletion: { (usedApp, fromMemory, openedLinkSuccessfully) in
                    if fromMemory {
                        print("Localide used \(usedApp) from user's previous choice.")
                    } else {
                        print("Localide " + (openedLinkSuccessfully ? "opened" : "failed to open") + " \(usedApp)")
                    }
                })
            }

            if Localide.sharedManager.availableMapApps.count == 1 {
                print("Only found 1 available app, opening it directly")
                let alertController = UIAlertController(title: "Only 1 App Found", message: "There's only one app found, Localide skips the prompt when there's only one valid option. Would you like to proceed?", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Proceed", style: .Default, handler: { _ in
                    promptFunction()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                promptFunction()
            }

        } else {

            let app = LocalideMapApp.AllMapApps[self.appChoiceSegmentControl.selectedSegmentIndex]
            if app.canOpenApp() {
                app.launchAppWithDirections(toLocation: location)
            } else {
                print("Unable to launch \(app.appName) ")
            }
        }
    }
}

// MARK: Configurations
extension ViewController {
    func configureConfigurationControls() {
        self.appChoiceSegmentControl.removeAllSegments()
        for (idx, app) in LocalideMapApp.AllMapApps.enumerate() {
            self.appChoiceSegmentControl.insertSegmentWithTitle(app.appName.componentsSeparatedByString(" ")[0], atIndex: idx, animated: true)
        }
        self.appChoiceSegmentControl.selectedSegmentIndex = 0
    }
    @IBAction func didChangeSelectedSegmentValue(sender: AnyObject) {
//        guard let segmentedControl = sender as? UISegmentedControl else { return }
    }
    @IBAction func didChangePromptSwitchValue(sender: AnyObject) {
        guard let switchControl = sender as? UISwitch else { return }

        self.rememberSwitch.enabled = switchControl.on
        self.appChoiceSegmentControl.enabled = !switchControl.on
    }
    @IBAction func didChangeRememberSwitchValue(sender: AnyObject) {
//        guard let switchControl = sender as? UISwitch else { return }
    }
}