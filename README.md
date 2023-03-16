# Phunware Mapping

[![Version](https://img.shields.io/cocoapods/v/PhunwareMapping.svg?style=flat-square)](https://cocoapods.org/pods/PhunwareMapping) [![License](https://img.shields.io/cocoapods/l/PhunwareMapping.svg?style=flat-square)](https://cocoapods.org/pods/PhunwareMapping) [![Platforms](https://img.shields.io/cocoapods/p/PhunwareMapping?style=flat-square)](https://cocoapods.org/pods/PhunwareMapping) [![Twitter](https://img.shields.io/badge/twitter-@phunware-blue.svg?style=flat-square)](https://twitter.com/phunware)

Phunware Mapping is a module that provides mapping and routing functionalities.

|Blue Dot|Route Builder|Route Directions|POI Categories|POI Search|
|:-:|:-:|:-:|:-:|:-:|
|![Blue Dot](https://raw.githubusercontent.com/phunware/maas-mapping-module-ios/master/Resources/bluedot.png)|![Route Builder](https://raw.githubusercontent.com/phunware/maas-mapping-module-ios/master/Resources/route-builder.png)|![Blue Dot](https://raw.githubusercontent.com/phunware/maas-mapping-module-ios/master/Resources/route-directions.png)|![POI Categories](https://raw.githubusercontent.com/phunware/maas-mapping-module-ios/master/Resources/poi-categories.png)|![Blue Dot](https://raw.githubusercontent.com/phunware/maas-mapping-module-ios/master/Resources/poi-search.png)|

## Requirements

- iOS 13+
- Xcode 14+

## Installation

### CocoaPods

It is required to use [CocoaPods](http://www.cocoapods.org) 1.10 or newer. Simply add the following to your Podfile:

```ruby
pod 'PhunwareMapping'
```

## Setup

To use any Phunware SDKs or Modules, you'll need to provide an App ID and Access Key during initialization via your application delegate's [application(_:didFinishLaunchingWithOptions:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application) method:

```swift
import PWCore

...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // App ID and Access Key can be found for your application in the MaaS portal at: http://maas.phunware.com/clients
    PWCore.setApplicationID("APPLICATION_ID", accessKey: "ACCESS_KEY")
    ...
}
```

## Usage

### Permissions

Precise Location permission is required for real-time location updates and blue dot tracking on the map. Priming the user for and requesting permissions is achieved by starting a `PermissionCoordinator`:

```swift
let permissionNavigationController = UINavigationController()
permissionNavigationController.modalPresentationStyle = .fullScreen
navigationController.present(permissionNavigationController, animated: true)

let coordinator = PermissionCoordinator(navigationController: permissionNavigationController,
                                        mapLocalization: mapLocalization,
                                        themeConfiguring: mapThemeConfigurator)
coordinator.delegate = self
cordinator.start()
```

### Routing

After precise location permission has been granted, launching the mapping experience is achieved by starting a `RoutingCoordinator`:

```swift
let coordinator = RoutingCoordinator(navigationController: navigationController,
                                     mapConfig: mapConfig,
                                     mapLocalization: mapLocalization,
                                     mapContainerSelector: mapContainerSelector,
                                     themeConfiguring: mapThemeConfigurator,
                                     allowsBackgroundLocationUpdates: false,
                                     meetingRoomPOIIdentifiers: [],
                                     initialMeetingRoomPOIImageSize: nil)
coordinator.delegate = self
coordinator.start()
```

## Theming

To configure theming, pass an object that conforms to `ThemeConfiguring` protocol when initializing `POICoordinator`, `RoutingCoordinator`, or `ShareLocationCoordinator`.

The module provides a default `MapThemeConfigurator` which allows theming configurations using `ColorPalette` and `TextStyles`:

```swift
let themeConfigurator = MapThemeConfigurator(
    colors: ColorPalette(
        primary: .systemBlue,
        secondary: .systemCyan,
        primaryVariant: .systemBlue,
        secondaryVariant: .systemCyan,
        background: .systemBackground,
        surface: .label,
        onPrimary: .label,
        onSecondary: .label,
        onBackground: .label,
        onSurface: .label,
        error: .systemRed,
        onError: .secondaryLabel
    ),
    texts: TextStyles(
        headline1: .boldSystemFont(ofSize: 28),
        headline2: .boldSystemFont(ofSize: 18),
        headline3: .systemFont(ofSize: 16),
        subtitle1: .boldSystemFont(ofSize: 16),
        subtitle2: .boldSystemFont(ofSize: 14),
        body1: .systemFont(ofSize: 14),
        body2: .systemFont(ofSize: 12),
        overline: .systemFont(ofSize: 12),
        caption: .boldSystemFont(ofSize: 12),
        button: .boldSystemFont(ofSize: 14)
    )
)

let coordinator = POICoordinator(
    ...
    themeConfiguring: themeConfigurator
)
```
