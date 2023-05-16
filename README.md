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

## Share My Location

### Loading Share My Location Map

1. Make sure instance of mapConfig is properly configured.
2. Make sure instance of mapLocalization is properly configured. 
3. Make sure instance of mapThemeConfigurator is properly configured.
4. Make sure instance of buildingGroundOverlayRenderers is properly configured.
5. Create a helper method in Coordinator class to run the share location map flow.
```swift
func runShareLocation() {
    guard let mapConfig = mapConfig,
          let mapLocalization = mapLocalization else {
        assertionFailure("mapConfig/mapLocalization should not be nil")
        return
    }

    let mapConfigInfo = MapConfigInfo(mapConfigKey: "map_config",
                                      mapName: "Sample Share My Location Map")

    let mapContainerSelector = MapContainerSelector(languageCode: mapLocalization.currentLanguageCode, 
                                                    mapName: mapConfigInfo.mapName)

    let childCoordinator = ShareLocationCoordinator(navigationController: navigationController,
                                                    mapConfig: mapConfig,
                                                    mapLocalization: mapLocalization,
                                                    mapContainerSelector: mapContainerSelector,
                                                    themeConfiguring: mapThemeConfigurator,
                                                    hidesBottomBarWhenPushed: true,
                                                    buildingGroundOverlayRenderers: buildingGroundOverlayRenderers)

    childCoordinator.delegate = self
    childCoordinators.append(childCoordinator)
    childCoordinator.start()
}
```

### Construct Share My Location URL

1. Implement ShareLocationCoordinatorDelegate to list
```swift
func coordinator(_ coordinator: ShareLocationCoordinator,
                 didRequestShareURLFor location: ShareableLocation,
                 withCompletionHandler completionHandler: @escaping (Result<URL, Error>) -> Void) {
    guard let floorID = location.floorID else {
        completionHandler(.failure(NSError(domain: "Nil floor ID", code: 0, userInfo: nil)))
        return
    }

    let deepLink = MappingDeeplink.routeBuilder(
        destination: .coordinate(
            mapConfigKey: mapConfigProvider.mapConfigKey,
            mapName: location.mapName,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            floorId: floorID
        )
    )

    guard let url = deepLink.url(withScheme: "phunwaremapping") else {
        completionHandler(.failure(NSError(domain: "Invalid share URL", code: 0, userInfo: nil)))
        return
    }

    completionHandler(.success(url))
}
```

### Opening Shared Locations

1. Make sure the App's Info.plist includes a URL types entry for the URL Scheme used when creating the Share My Location URL. This will ensure tapping a link configured with this sheme will open the App when installed on device.
2. Implement MappingDeeplinkNavigable -> queryCanOpenDirectly
```swift
func queryCanOpenDirectly(_ deeplink: MappingDeeplink, completion: @escaping (Bool) -> Void) {
    let canChildCoordinatorHandleDeeplink: Bool = {
        childCoordinators.contains(where: { $0 is MappingDeeplinkNavigable })
        && currentMapName == deeplink.mapName
    }()

    if !canChildCoordinatorHandleDeeplink {
        // We don't have a child coordinator that can handle the deeplink, so we have to
        // handle it ourselves.
        completion(true)
    } else {
        // We DO have a child coordinator that can handle the deeplink, so complete with false
        // and let the child mapping deeplink navigable handle it.
        completion(false)
    }
}
```    
3. Implement MappingDeeplinkNavigable -> prepareForNavigation
```swift
func prepareForNavigation(to deeplink: MappingDeeplink) {
    let childCoordinatorRequiresRemoval: Bool = {
        childCoordinators.contains(where: { $0 is MappingDeeplinkNavigable })
        && currentMapName != deeplink.mapName
    }()

    if childCoordinatorRequiresRemoval,
       let activeMappingCoordinator = childCoordinators.first(where: {
           $0 is POICoordinator || $0 is RoutingCoordinator
       }) {
        removeChildCoordinator(activeMappingCoordinator)
        navigationController.dismiss(animated: false)
        navigationController.popToRootViewController(animated: true)
    }
}
```    
4. Implement MappingDeeplinkNavigable -> openDeeplink
```swift
func openDeeplink(_ deeplink: MappingDeeplink) -> Bool {
    // If we don't have a child coordinator that can handle the deeplink, we'll need to create one first.
    if !childCoordinators.contains(where: { $0 is MappingDeeplinkNavigable }) {
        if let deeplinkMapConfigKey = deeplink.mapConfigKey,
           let deeplinkMapName = deeplink.mapName, 
           currentMapConfigKey != deeplink.mapConfigKey {
            // We must update current map config
            updateMapConfigKey(deeplinkMapConfigKey)
            reloadMapConfig() {
                self.runPOI(mapConfigInfo: .init(mapConfigKey: deeplinkMapConfigKey, mapName: deeplinkMapName))
            }
        } else if let mapName = deeplink.mapName {
            // Otherwise use current map config
            runPOI(mapConfigInfo: .init(mapConfigKey: currentMapConfigKey, mapName: mapName))
        } else {
            // Not enough information, use default
            runPOI(mapConfigInfo: .init(mapConfigKey: currentMapConfigKey, mapName: MapName.default.rawValue))
        }
    }

    guard let mappingDeepLinkHandler = childCoordinators.compactMap({ $0 as? MappingDeeplinkNavigable }).first else {
        assertionFailure("A MappingDeeplinkNavigable must exist in order to follow deeplink: \(deeplink)")
        return false
    }

    mappingDeepLinkHandler.followDeeplink(deeplink)
    return true
}
```
