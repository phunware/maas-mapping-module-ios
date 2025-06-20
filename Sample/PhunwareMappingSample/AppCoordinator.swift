//
//  AppCoordinator.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 1/26/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareFoundation
import PhunwareCorePlugin
import PhunwareMapping
import PWCore
import CoreLocation
import MapKit
import SafariServices

class AppCoordinator: NSObject, Coordinator {

    private let urlTypeName = "UniversalLinkDomain"
    private var universalLinkDomain: String {
        guard let scheme = Bundle.main.urlTypes.first(where: { $0.name == urlTypeName })?.schemes.first else {
            assertionFailure("A URL type with the identifier \"\(urlTypeName)\" is missing from the Info.plist key 'CFBundleURLTypes' or it has no URL schemes for the key 'CFBundleURLSchemes'. A URL scheme for this URL type is necessary in order to deeplink to the Phunware Mapping Module.")
            return "module-sample-apps.firebaseapp.com"
        }
        
        return scheme
    }
    var shareMyLocationMatchingURLString: String {
      "https://\(universalLinkDomain)/mapping"
    }
    
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    
    var childMappingDeeplinkHandlers = [MappingDeeplinkNavigable]()
    var pendingMappingDeeplink: DeferredMappingDeeplink?
    var isMappingDeeplinkingAvailable = false
    
    lazy var maasConfig: MaasConfig = {
        switch MapConfigKey.default {
        case .austinOffice:
            return .phunwareVerticalSolutionsOrganization
        }
    }()
        
    private lazy var mapConfigProvider: MapConfigProvider = {
        return StubMapConfigProvider()
    }()
    
    private lazy var mapLocalizationProvider: MapLocalizationProvider = {
        return StubMapLocalizationProvider()
    }()
    
    private var mapConfig: MapConfig?
    
    private var mapLocalization: MapLocalization?
    
    private var currentMapConfigKey: String = MapConfigKey.default.rawValue

    private var currentMapName: String?
    
    private var currentMapConfigInfo: MapConfigInfo? {
        guard let currentMapName else { return nil }
        return mapConfigInfo(for: currentMapName, mapConfigKey: currentMapConfigKey)
    }
    
    private var mappingModule: MappingModule?
    
    private var currentMappingConfiguration: MappingConfiguration?
    
    private var homeToVenueMonitor: HomeToVenueMonitor?
    
    private lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()
        
    private func mapContainerSelector(for mapConfigInfo: MapConfigInfo) -> MapContainerSelector {
        guard let mapLocalization = mapLocalization else {
            fatalError("mapLocalization is nil")
        }
        return MapContainerSelector(languageCode: mapLocalization.currentLanguageCode, mapName: mapConfigInfo.mapName)
    }
    
    private lazy var mapThemeConfigurator = MapThemeConfigurator.current
    
    private var cachedMeetingRooms: [MeetingRoom]?
    
    private lazy var standardPOIImageSize: CGSize = {
        // Constants taken from the Phunware Map SDK
        if UIDevice.current.userInterfaceIdiom == .phone {
            return CGSize(width: 28.5, height: 24.0)
        } else {
            return CGSize(width: 28.5 * 5/4, height: 24.0 * 5/4)
        }
    }()
    
    private let buildingGroundOverlayRenderers: [BuildingGroundOverlayRenderer] = {
        let coordinate = CLLocationCoordinate2D(latitude: 33.02191, longitude: -117.0826)
        var boundingMapRect = MKMapRect(origin: MKMapPoint(coordinate), size: MKMapSize(width: 0, height: 0))
        boundingMapRect = boundingMapRect.insetBy(dx: -1000, dy: -1000)
        let overlay = MapOverlay(coordinate: coordinate, boundingMapRect: boundingMapRect)
        let overviewImage = UIImage(named: "map_background_blue")!
        let buildingImage = UIImage(named: "map_background_red")!
        let overviewGroundRenderer = MapImageOverlayRenderer(overlay: overlay, image: overviewImage)
        let building1GroundRenderer = MapImageOverlayRenderer(overlay: overlay, image: buildingImage)
        let overviewGroundOverlayRenderer = BuildingGroundOverlayRenderer(buildingIdentifiers: [116767],
                                                                          groundRenderer: overviewGroundRenderer)
        let building1GroundOverlayRenderer = BuildingGroundOverlayRenderer(buildingIdentifiers: [116773],
                                                                           groundRenderer: building1GroundRenderer)
        
        return [overviewGroundOverlayRenderer, building1GroundOverlayRenderer]
    }()
    
    private lazy var shareLocationURLGenerator = ShareLocationURLGenerator(universalLinkDomain: self.universalLinkDomain)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setupPWCore()
        runAppLaunch()
    }
}

// MARK: - Flows
private extension AppCoordinator {
        
    func setupPWCore() {
        PWAnalytics.enableAutomaticScreenViewEvents(false)
        PWCore.setEnvironment(maasConfig.environment)
        PWCore.setApplicationID(maasConfig.applicationID, accessKey: maasConfig.accessKey)
    }
    
    func runAppLaunch() {
        let viewController = AppLaunchViewController.makeFromStoryboard()
        let viewModel = AppLaunchViewModel(mapConfigProvider: mapConfigProvider,
                                           mapLocalizationProvider: mapLocalizationProvider,
                                           mapConfigKey: MapConfigKey.default.rawValue)
        viewController.viewModel = viewModel
        viewModel.delegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func runLocationPermission() {
        let childCoordinator = PermissionCoordinator(navigationController: navigationController,
                                                     mapLocalization: mapLocalization!,
                                                     mapTheme: mapThemeConfigurator.configureTheme(),
                                                     completionNavigationAction: .none)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    func runDemo() {
        let buildingMapConfigInfo: MapConfigInfo = {
            switch MapConfigKey.default {
            case .austinOffice: MapConfigInfo.austinOfficeBuilding
            }
        }()
        
        let campusMapConfigInfo: MapConfigInfo? = {
            switch MapConfigKey.default {
            case .austinOffice: MapConfigInfo.austinOfficeCampus
            }
        }()
        
        let viewController = DemoViewController.makeFromStoryboard()
        let viewModel = DemoViewModel(applicationIdentifier: maasConfig.applicationID,
                                      organization: maasConfig.organization,
                                      mapConfigKey: currentMapConfigKey,
                                      buildingMapConfigInfo: buildingMapConfigInfo,
                                      campusMapConfigInfo: campusMapConfigInfo)
        viewController.viewModel = viewModel
        viewModel.delegate = self
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    func runAppLink() {
        let viewController = AppLinkViewController.makeFromStoryboard()
        let viewModel = AppLinkViewModel()
        viewController.viewModel = viewModel
        viewModel.delegate = self
        let navController = UINavigationController(rootViewController: viewController)
        navigationController.present(navController, animated: true)
    }
    
    func runMappingModule(_ config: MapConfigInfo) {
        guard let mapConfig,
              let mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        
        // Map Tab
        let mapTabNavController = UINavigationController()
        mapTabNavController.view.backgroundColor = .systemBackground
        mapTabNavController.tabBarItem = .init(title: "Map Tab", image: UIImage(systemName: "map"), tag: 0)
        
        let mappingModule = MappingModule(themeConfigurator: MapThemeConfigurator.current,
                                          homeToVenueConfiguration: .init(urlTypeName: urlTypeName,
                                                                          notificationText: "H2V Notification Text"),
                                          delegate: self)
        
        self.mappingModule = mappingModule
        let meetingRoom = MappingConfiguration.MeetingRoom(meetingRoomPOIIdentifiers: meetingRoomPOIIdentifiers(for: config),
                                                           initialMeetingRoomPOIImageSize: standardPOIImageSize)
        currentMapName = config.mapName
        currentMappingConfiguration = .init(mapConfigKey: config.mapName,
                                            mapConfig: mapConfig,
                                            mapLocalization: mapLocalization,
                                            meetingRoom: meetingRoom)
        homeToVenueMonitor = nil
        
        guard let coordinator = mappingModule.coordinator(for: "mapping/mapId=\(config.mapName)", using: mapTabNavController) else {
            return
        }
        
        // Share My Location Tab
        let shareLocationNavController = UINavigationController()
        shareLocationNavController.view.backgroundColor = .systemBackground
        shareLocationNavController.tabBarItem = .init(title: "Share Location", image: UIImage(systemName: "mappin.and.ellipse"), tag: 1)
        let shareLocationLauncherCoordinator = ShareLocationLauncherCoordinator(
            navigationController: shareLocationNavController,
            mapConfig: mapConfig,
            mapLocalization: mapLocalization,
            mapContainerSelector: mapContainerSelector(for: config),
            configInfo: config,
            shareLocationURLGenerator: shareLocationURLGenerator
        )
        
        let tabCoordinators = [coordinator, shareLocationLauncherCoordinator]
        let tabBarController = UITabBarController()
        tabBarController.loadViewIfNeeded()
        tabBarController.viewControllers = tabCoordinators.map { $0.navigationController }
        
        tabCoordinators.forEach { coordinator in
            childCoordinators.append(coordinator)
            
            if let mappingDeeplinkHandler = coordinator as? MappingDeeplinkNavigable {
                childMappingDeeplinkHandlers.append(mappingDeeplinkHandler)
            }
            
            coordinator.start()
        }
        
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(tabBarController, animated: true)
        
        startMonitoringRegion()
    }
    
    func runPOI(_ config: MapConfigInfo) {
        guard let mapConfig,
              let mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        
        currentMapName = config.mapName
        homeToVenueMonitor = HomeToVenueMonitor(configuration: .init(urlTypeName: urlTypeName,
                                                                     notificationText: "H2V Notification Text"))
        
        let mapContainerSelector = mapContainerSelector(for: config)
        let childCoordinator = POICoordinator(navigationController: navigationController,
                                              mapConfig: mapConfig,
                                              mapLocalization: mapLocalization,
                                              mapContainerSelector: mapContainerSelector,
                                              mapTheme: mapThemeConfigurator.configureTheme(),
                                              hidesBottomBarWhenPushed: true,
                                              meetingRoomPOIIdentifiers: meetingRoomPOIIdentifiers(for: config),
                                              initialMeetingRoomPOIImageSize: standardPOIImageSize,
                                              buildingGroundOverlayRenderers: buildingGroundOverlayRenderers)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childMappingDeeplinkHandlers.append(childCoordinator)
        childCoordinator.start()
        
        if let cachedMeetingRooms = cachedMeetingRooms {
            childCoordinator.setMeetingRooms(cachedMeetingRooms)
        }
        
        startMonitoringRegion()
    }
    
    func runShareLocation(_ config: MapConfigInfo) {
        guard let mapConfig,
              let mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        let childCoordinator = ShareLocationCoordinator(navigationController: navigationController,
                                                        mapConfig: mapConfig,
                                                        mapLocalization: mapLocalization,
                                                        mapContainerSelector: mapContainerSelector(for: config),
                                                        mapTheme: mapThemeConfigurator.configureTheme(),
                                                        hidesBottomBarWhenPushed: true,
                                                        buildingGroundOverlayRenderers: buildingGroundOverlayRenderers)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
        currentMapName = config.mapName
        homeToVenueMonitor = nil
    }

    func runOpenURL(_ url: URL) {
        if url.canOpenInSFSafariViewController {
            let viewController = SFSafariViewController(url: url)
            navigationController.topmostPresentedViewController.present(viewController, animated: true, completion: nil)
        } else {
                UIApplication.shared.open(url) { [weak self] opened in
                    guard let self = self else { return }
                    
                    if !opened {
                        self.runAlert(title: "", message: "This URL (\(url.absoluteString)) is not supported by iOS.")
                    }
                }
            }
        }

    func runPhoneService(phoneNumberURL: URL) {
        UIApplication.shared.open(phoneNumberURL)
    }
    
    func runAlert(title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        navigationController.present(alertController, animated: true)
    }
    
    func startMonitoringRegion() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self),
              let homeToVenue = currentMapConfigInfo?.homeToVenue else {
            return
        }
        
        guard !locationManager.monitoredRegions.contains(where: { $0.identifier == homeToVenue.geozones.first?.identifier }) else { return }
        
        let maxDistance: CLLocationDistance = homeToVenue.geofenceMeter
        homeToVenue.geozones.forEach { geozone in
            let center = CLLocationCoordinate2D(latitude: geozone.location.latitude,
                                                longitude: geozone.location.longitude)
            let region = CLCircularRegion(center: center, radius: maxDistance, identifier: geozone.identifier)
            locationManager.startMonitoring(for: region)
        }
    }
}

// MARK: - PermissionCoordinatorDelegate
extension AppCoordinator: PermissionCoordinatorDelegate {
    
    public func coordinator(_ coordinator: PermissionCoordinator, customImageWithName name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    public func coordinatorDidFinish(_ coordinator: PermissionCoordinator) {
        removeChildCoordinator(coordinator)
        
        runDemo()
    }
}

// MARK: - AppLaunchViewModelDelegate
extension AppCoordinator: AppLaunchViewModelDelegate {
    func viewModel(_ viewModel: AppLaunchViewModel, didFinishLoading mapConfig: MapConfig, mapLocalizationDict: MapLocalizationDictionary) {
        self.mapConfig = mapConfig
        
        let defaultLanguageCode = mapConfig.languages?.compactMap { $0.code }.first ?? "en"
        let mapLocalization = MapLocalization(with: defaultLanguageCode)
        mapLocalization.setLocalization(localizationDictionary: mapLocalizationDict)
        self.mapLocalization = mapLocalization
        
        runLocationPermission()
    }
    
    func viewModel(_ viewModel: AppLaunchViewModel, didFailWith error: Error) {
        runAlert(title: "Error", message: error.localizedDescription)
    }
}

// MARK: - DemoViewModelDelegate
extension AppCoordinator: DemoViewModelDelegate {
    func viewModelViewDidAppear(_ viewModel: DemoViewModel) {
        guard !isMappingDeeplinkingAvailable else { return }
        
        isMappingDeeplinkingAvailable = true
        
        DispatchQueue.main.async {
            self.followPendingMappingDeeplinkIfAvailable()
        }
    }
        
    func viewModel(_ viewModel: DemoViewModel,
                   didSelectMapFor mapConfigInfo: MapConfigInfo,
                   embeddedInTab: Bool) {
        if embeddedInTab {
            runMappingModule(mapConfigInfo)
        } else {
            runPOI(mapConfigInfo)
        }
    }
    
    func viewModel(_ viewModel: DemoViewModel, didSelectShareLocationFor mapConfigInfo: MapConfigInfo) {
        if mapConfigInfo.mapConfigKey == currentMapConfigKey {
            runShareLocation(mapConfigInfo)
        } else {
            updateMapConfigKey(mapConfigInfo.mapConfigKey)
            reloadMapConfig() {
                self.runShareLocation(mapConfigInfo)
            }
        }
    }
    
    func viewModelDidSelectAppLink(_ viewModel: DemoViewModel) {
        runAppLink()
    }
}

// MARK: - MappingModuleDelegate
extension AppCoordinator: MappingModuleDelegate {
    func mappingModule(_ module: MappingModule, didRequestShareURLFor location: ShareableLocation, withCompletionHandler completionHandler: @escaping (Result<ShareLocationURLs, Error>) -> Void) {
        shareLocationURLGenerator.generateShareLocationURL(for: location,
                                                           mapConfigKey: currentMapConfigKey,
                                                           withCompletionHandler: completionHandler)
    }
    
    func mappingModule(_ module: MappingModule, didRequestMeetingRoomsFor poiIdentifiers: [String], completion: @escaping (Result<[MeetingRoom], Error>) -> Void) {
        requestMeetingRoomStatuses(for: poiIdentifiers, completion: completion)
    }
    
    func mappingModuleDidRequestConfiguration(_ module: MappingModule) -> MappingConfiguration? {
        currentMappingConfiguration
    }
}

// MARK: - Private Helpers
private extension AppCoordinator {
    
    func meetingRoomPOIIdentifiers(for config: MapConfigInfo) -> [String] {
        guard let mapName = MapName(rawValue: config.mapName) else { return [] }
        
        switch mapName {
        case .campus:
            return ["60603734", "60796992", "60603322"]
        case .building:
            return ["45361237", "42539820", "42539817", "42539835"]
        }
    }

    func didSelectActionLink(_ actionLink: ActionLink) {
        switch actionLink.type {
            case .weblink:
                if let urlString = actionLink.actionContent,
                   let url = URL(string: urlString) {
                    runOpenURL(url)
                }

            case .phone:
                if let url = actionLink.actionContent?.normalizedPhoneURL() {
                    runPhoneService(phoneNumberURL: url)
                }

            default:
                // Nothing else handled yet.
                break
        }
    }
    
    func removeChildMappingDeeplinkHandler(_ handler: MappingDeeplinkNavigable) {
        childMappingDeeplinkHandlers.removeAll(where: { $0 === handler })
    }
    
    func requestMeetingRoomStatuses(for poiIdentifiers: [String],
                                    completion: @escaping (Result<[MeetingRoom], Error>) -> Void) {
        // Simulate network call(s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let meetingRooms: [MeetingRoom] = poiIdentifiers.map {
                
                // Fake some meeting room statuses by just generating random ones
                let randomStatus: MeetingRoom.Status
                switch Int.random(in: 0...4) {
                case 0:
                    randomStatus = .available
                case 1:
                    randomStatus = .occupied
                case 2:
                    randomStatus = .unavailable
                case 3:
                    randomStatus = .default
                default:
                    randomStatus = .unknown
                }
                
                return MeetingRoom(
                    maasPOIId: $0,
                    status: randomStatus,
                    poiImageSize: CGSize(width: 59.0, height: 50.0)
                )
            }
            
            self.cachedMeetingRooms = meetingRooms
            
            // Call the passed-in completion handler
            completion(.success(meetingRooms))
        }
    }
    
    func updateMapConfigKey(_ key: String) {
        currentMapConfigKey = key
    }
    
    func reloadMapConfig(completion: (() -> Void)? = nil) {
        weak var weakSelf = self
                
        let loadMapLocalization: ((MapConfig?) -> Void) = { (mapConfig) in
            guard let self = weakSelf else { return }

            let supportedLanguages = mapConfig?.languages ?? []
            self.mapLocalizationProvider.fetchMapLocalization(for: supportedLanguages) { localizationResult in
                guard let self = weakSelf else { return }
                
                switch localizationResult {
                    case .success(let dict):
                        let defaultLanguageCode = mapConfig?.languages?.compactMap { $0.code }.first ?? "en"

                        let mapLocalization = MapLocalization(with: defaultLanguageCode)
                        mapLocalization.setLocalization(localizationDictionary: dict)

                        self.mapConfig = mapConfig
                        self.mapLocalization = mapLocalization
                    
                    case .failure(let error):
                        print("Failed to fetch map localization with error: \"\(error.localizedDescription)\".")
                        self.mapConfig = nil
                        self.mapLocalization = nil
                }
                
                completion?()
            }
        }

        mapConfigProvider.fetchMapConfig(using: currentMapConfigKey) { configResult in
            switch configResult {
            case .success(let mapConfig):
                loadMapLocalization(mapConfig)
            case .failure(let error):
                print("Failed to load map config with error: \"\(error.localizedDescription)\".")
                completion?()
            }
        }
    }
    
    func reloadMapConfigIfNeeded(completion: (() -> Void)? = nil) {
        if currentMapConfigKey != MapConfigKey.default.rawValue {
            updateMapConfigKey(MapConfigKey.default.rawValue)
            reloadMapConfig(completion: completion)
        }
    }
    
    func mapConfigInfo(for mapName: String, mapConfigKey: String) -> MapConfigInfo? {
        let info: [MapConfigInfo] = [.austinOfficeBuilding, .austinOfficeCampus]
        return info.first { $0.mapName == mapName && $0.mapConfigKey == mapConfigKey }
    }
}

// MARK: - POICoordinatorDelegate
extension AppCoordinator: POICoordinatorDelegate {

    func coordinatorDidFinish(_ coordinator: POICoordinator) {
        reloadMapConfigIfNeeded()
        currentMapName = nil
        
        removeChildCoordinator(coordinator)
        removeChildMappingDeeplinkHandler(coordinator)
    }

    func coordinator(_ coordinator: POICoordinator, didSelectActionLink actionLink: ActionLink) {
        didSelectActionLink(actionLink)
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didStartHomeToVenueRoutingWith geozoneIdentifiers: Set<String>,
                     destination: HomeToVenueDestination) {
        homeToVenueMonitor?.didStartHomeToVenueRoutingWith(geozoneIdentifiers: geozoneIdentifiers, destination: destination)
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didStopHomeToVenueRoutingWith geozoneIdentifiers: Set<String>) {
        homeToVenueMonitor?.didStopHomeToVenueRoutingWith(geozoneIdentifiers: geozoneIdentifiers)
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didRequestMeetingRoomsFor poiIdentifiers: [String],
                     completion: @escaping (Result<[MeetingRoom], Error>) -> Void) {
        requestMeetingRoomStatuses(for: poiIdentifiers, completion: completion)
    }
}

// MARK: - ShareLocationCoordinatorDelegate
extension AppCoordinator: ShareLocationCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ShareLocationCoordinator) {
        reloadMapConfigIfNeeded()
        currentMapName = nil
        
        removeChildCoordinator(coordinator)
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator,
                     didRequestShareURLFor location: ShareableLocation,
                     withCompletionHandler completionHandler: @escaping (Result<ShareLocationURLs, Error>) -> Void) {
        shareLocationURLGenerator.generateShareLocationURL(for: location,
                                                           mapConfigKey: currentMapConfigKey,
                                                           withCompletionHandler: completionHandler)
    }
}

// MARK: - MappingDeeplinkNavigable
extension AppCoordinator: MappingDeeplinkNavigable {
    
    private var mappingDeeplinkHandler: MappingDeeplinkNavigable? {
        childMappingDeeplinkHandlers.first
    }
    
    private func canChildCoordinatorHandleDeeplink(_ deeplink: MappingDeeplink) -> Bool {
        mappingDeeplinkHandler != nil && currentMapName == deeplink.mapName
    }
    
    public func queryCanOpenDirectly(_ deeplink: MappingDeeplink, completion: @escaping (Bool) -> Void) {
        if !canChildCoordinatorHandleDeeplink(deeplink) {
            // We don't have a child coordinator that can handle the deeplink, so we have to
            // handle it ourselves.
            completion(true)
        } else {
            // We DO have a child coordinator that can handle the deeplink, so complete with false
            // and let the child mapping deeplink navigable handle it.
            completion(false)
        }
    }
    
    public func prepareForNavigation(to deeplink: MappingDeeplink) {
        navigationController.dismiss(animated: false)
        
        if !canChildCoordinatorHandleDeeplink(deeplink),
        let coordinator = childCoordinators.first {
            if let handler = coordinator as? MappingDeeplinkNavigable {
                removeChildMappingDeeplinkHandler(handler)
            }
            removeChildCoordinator(coordinator)
            navigationController.popToRootViewController(animated: false)
        }
    }
    
    public func openDeeplink(_ deeplink: MappingDeeplink) -> Bool {
        let runPOIAndDeeplink: (String, String, HomeToVenueInfo) -> Void = { [weak self] mapConfigKey, mapName, homeToVenue in
            guard let self else { return }
            
            self.runPOI(.init(mapConfigKey: mapConfigKey, mapName: mapName, homeToVenue: homeToVenue))
            self.mappingDeeplinkHandler?.followDeeplink(deeplink)
        }
        
        if let mappingDeeplinkHandler {
            mappingDeeplinkHandler.followDeeplink(deeplink)
        } else {
            let mapConfigKey = deeplink.mapConfigKey ?? MapConfigKey.default.rawValue
            let mapName = deeplink.mapName ?? MapName.building.rawValue
            let homeToVenue = currentMapConfigInfo?.homeToVenue ?? HomeToVenueInfo()
            
            if let deeplinkMapConfigKey = deeplink.mapConfigKey,
               deeplinkMapConfigKey != currentMapConfigKey {
                updateMapConfigKey(deeplinkMapConfigKey)
                reloadMapConfig() {
                    runPOIAndDeeplink(mapConfigKey, mapName, homeToVenue)
                }
            } else {
                runPOIAndDeeplink(mapConfigKey, mapName, homeToVenue)
            }
        }
        
        return true
    }
}

// MARK: - AppLinkViewModelDelegate
extension AppCoordinator: AppLinkViewModelDelegate {
    
    func viewModel(_ viewModel: AppLinkViewModel, didSelectAppLink appLink: AppLink) {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            if let deeplink = appLink.deeplink,
               let resolver = DeeplinkResolver(deeplink) {
                
                switch resolver {
                case .mapping(let mappingDeeplink):
                    self.followDeeplink(mappingDeeplink)
                    
                case .map(let mapName):
                    if let mapConfigInfo = mapConfigInfo(for: mapName, mapConfigKey: currentMapConfigKey) {
                        self.runPOI(mapConfigInfo)
                    }
                    
                case .tabNavigation(let mapName):
                    if let mapConfigInfo = mapConfigInfo(for: mapName, mapConfigKey: currentMapConfigKey) {
                        self.runMappingModule(mapConfigInfo)
                    }
                    
                case .shareLocation(let mapName):
                    if let mapConfigInfo = mapConfigInfo(for: mapName, mapConfigKey: currentMapConfigKey) {
                        self.runShareLocation(mapConfigInfo)
                    }
                }
            }
        }
    }
    
    func viewModelDidFinish(_ viewModel: AppLinkViewModel) {
        navigationController.dismiss(animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension AppCoordinator: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        homeToVenueMonitor?.didEnterGeozone(geozoneIdentifier: region.identifier)
        mappingModule?.didEnterGeozone(geozoneIdentifier: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        homeToVenueMonitor?.didExitGeozone(geozoneIdentifier: region.identifier)
        mappingModule?.didExitGeozone(geozoneIdentifier: region.identifier)
    }
}
