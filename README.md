# Localide
#### Localide is an easy helper to offer users a personalized experience by using their favorite installed apps for directions.
![Localide Screenshot](http://s33.postimg.org/iob7lrl0v/Simulator_Screen_Shot_Jun_4_2016_12_38_30_PM.png)

### Requierments
  - Swift
  - iOS 8.0+
  - Xcode 7.3

### Installation

CocoaPods:
```sh
pod 'Localide', '~> 2.1'
```

Carthage:
```sh
github "davoda/Localide"
```

Manual:
Add the [Localide Classes'](https://github.com/davoda/Localide/tree/master/Localide/Classes) files to your project

### Usage

Firstly insert all Third Party Apps' URL schemes to your **Info.plist**:

*LSApplicationQueriesSchemes:*
 - citymapper ([Citymapper App](https://itunes.apple.com/us/app/citymapper-real-time-transit/id469463298?mt=8))
 - comgooglemaps ([Google Maps App](https://itunes.apple.com/us/app/google-maps-real-time-navigation/id585027354?mt=8))
 - navigon ([Navigon App](https://itunes.apple.com/us/app/navigon-usa/id384680007?mt=8))
 - transit ([Transit App](https://itunes.apple.com/us/app/transit-app-real-time-tracker/id498151501?mt=8))
 - waze ([Waze App](https://itunes.apple.com/us/app/waze-gps-navigation-maps-social/id323229106?mt=8))
 - yandexnavi ([Yandex Navigator](https://itunes.apple.com/us/app/yandex.navigator/id474500851?mt=8))

**Info.plist should [look like this](http://s33.postimg.org/srpqbka3z/Screen_Shot_2016_05_31_at_6_28_56_PM.png "Info.plist should look like this.").**

##### Giving the user the option to use their favorite installed app
```swift
let location = CLLocationCoordinate2D(latitude: 37.776692, longitude: 0.0)
Localide.sharedManager.promptForDirections(toLocation: location,  { (usedApp, fromMemory, openedLinkSuccessfully) in
    print("The user picked \(usedApp.name)")
}
```

###### Other Options
- You may also choose to have Localide remember the user's choice for future directions by using the ```rememberPreference ``` argument.
- You may also choose to restrict the user from using some applications by using the ```usingASubsetOfApps``` argument.


##### Specific App
You can launch the Apple Maps app with directions to location by using:
```swift
let location = CLLocationCoordinate2D(latitude: 37.776692, longitude: 0.0)
Localide.sharedManager.launchNativeAppleMapsAppForDirections(toLocation: location)
```

For other apps:
```swift
if LocalideMapApp.GoogleMaps.canOpenApp() {
    let location = CLLocationCoordinate2D(latitude: 37.776692, longitude: 0.0)
    LocalideMapApp.GoogleMaps.launchAppWithDirections(toLocation: location)
}
```
### Pipeline
 - Support addresses
 - Ask user if they wish to use the same app in the future.
