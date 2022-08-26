//
//  AppCoordinator.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit
import PhunwareFoundation
import PhunwareMapping
import PWCore

class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    
    var childMappingDeeplinkHandlers = [MappingDeeplinkNavigable]()
    var pendingMappingDeeplink: DeferredMappingDeeplink?
    
    private lazy var maasConfig: MaasConfig = {
        let applicationID = ""
        let accessKey = ""
        
        guard !applicationID.isEmpty,
              !accessKey.isEmpty else {
            fatalError("An application ID and access key are required but missing.")
        }
        
        return MaasConfig(environment: .prod,
                          applicationID: applicationID,
                          accessKey: accessKey)
    }()
    
    private lazy var mapConfigProvider: MapConfigProvider = {
        return StubMapConfigProvider()
    }()
    
    private lazy var mapLocalizationProvider: MapLocalizationProvider = {
        return StubMapLocalizationProvider()
    }()
    
    private var mapConfig: MapConfig?
    
    private var mapLocalization: MapLocalization?
    
    private func mapContainerSelector(for mapContainerKind: DemoViewModel.MapContainerKind) -> MapContainerSelector {
        guard let mapLocalization = mapLocalization else {
            fatalError("mapLocalization is nil")
        }
        
        let mapName: String
        switch mapContainerKind {
        case .campus:
            mapName = "Multi-Building"
            
        case .building:
            mapName = "Single Building"
        }
        
        return MapContainerSelector(languageCode: mapLocalization.currentLanguageCode, mapName: mapName)
    }
    
    private lazy var mapThemeConfigurator = MapThemeConfigurator.current
    
    private var cachedMeetingRooms: [MeetingRoom]?
    
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
        let viewModel = AppLaunchViewModel(mapConfigProvider: mapConfigProvider, mapLocalizationProvider: mapLocalizationProvider)
        viewController.viewModel = viewModel
        viewModel.delegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func runLocationPermission() {
        guard CLLocationManager.authorizationStatus() == .notDetermined else {
            runDemo()
            return
        }
        
        guard let mapLocalization = mapLocalization else {
            assertionFailure("mapLocalization is nil")
            return
        }
        
        let permissionNavigationController = UINavigationController()
        permissionNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(permissionNavigationController, animated: true)
        let childCoordinator = PermissionCoordinator(navigationController: permissionNavigationController,
                                                     mapLocalization: mapLocalization,
                                                     themeConfiguring: mapThemeConfigurator)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
    
    func runDemo() {
        let viewController = DemoViewController.makeFromStoryboard()
        let viewModel = DemoViewModel()
        viewController.viewModel = viewModel
        viewModel.delegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func runPOI(mapContainerKind: DemoViewModel.MapContainerKind) {
        guard let mapConfig = mapConfig,
              let mapLocalization = mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        
        // Constants taken from the Phunware Map SDK:
        let standardPOIImageSize: CGSize
        if UIDevice.current.userInterfaceIdiom == .phone {
            standardPOIImageSize = CGSize(width: 28.5, height: 24.0)
        } else {
            standardPOIImageSize = CGSize(width: 28.5 * 5/4, height: 24.0 * 5/4)
        }
        
        // The app tells the mapping module which POIs are meant to be "meeting rooms":
        let meetingRoomPOIIdentifiers: [String]
        switch mapContainerKind {
        case .campus:
            meetingRoomPOIIdentifiers = ["60603734", "60796992", "60603322"]
            
        case .building:
            meetingRoomPOIIdentifiers = ["45361237", "42539820", "42539817", "42539835"]
        }
        
        let childCoordinator = POICoordinator(navigationController: navigationController,
                                              mapConfig: mapConfig,
                                              mapLocalization: mapLocalization,
                                              mapContainerSelector: mapContainerSelector(for: mapContainerKind),
                                              themeConfiguring: mapThemeConfigurator,
                                              allowsBackgroundLocationUpdates: false,
                                              hidesBottomBarWhenPushed: true,
                                              meetingRoomPOIIdentifiers: meetingRoomPOIIdentifiers,
                                              initialMeetingRoomPOIImageSize: standardPOIImageSize,
                                              buildingGroundOverlayRenderers: nil)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childMappingDeeplinkHandlers.append(childCoordinator)
        childCoordinator.start()
        
        if let cachedMeetingRooms = cachedMeetingRooms {
            childCoordinator.setMeetingRooms(cachedMeetingRooms)
        }
    }
    
    func runRouting(mapContainerKind: DemoViewModel.MapContainerKind) {
        guard let mapConfig = mapConfig,
              let mapLocalization = mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        
        // Constants taken from the Phunware Map SDK:
        let standardPOIImageSize: CGSize
        if UIDevice.current.userInterfaceIdiom == .phone {
            standardPOIImageSize = CGSize(width: 28.5, height: 24.0)
        } else {
            standardPOIImageSize = CGSize(width: 28.5 * 5/4, height: 24.0 * 5/4)
        }
        
        // The app tells the mapping module which POIs are meant to be "meeting rooms":
        let meetingRoomPOIIdentifiers: [String]
        switch mapContainerKind {
        case .campus:
            meetingRoomPOIIdentifiers = ["12345678", "87654321"]
            
        case .building:
            meetingRoomPOIIdentifiers = ["12345678", "87654321"]
        }
        
        let childCoordinator = RoutingCoordinator(navigationController: navigationController,
                                                  mapConfig: mapConfig,
                                                  mapLocalization: mapLocalization,
                                                  mapContainerSelector: mapContainerSelector(for: mapContainerKind),
                                                  themeConfiguring: mapThemeConfigurator,
                                                  allowsBackgroundLocationUpdates: false,
                                                  hidesBottomBarWhenPushed: true,
                                                  meetingRoomPOIIdentifiers: meetingRoomPOIIdentifiers,
                                                  initialMeetingRoomPOIImageSize: standardPOIImageSize,
                                                  buildingGroundOverlayRenderers: buildingGroundOverlayRenderers)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childMappingDeeplinkHandlers.append(childCoordinator)
        childCoordinator.start()
    }
    
    func runShareLocation(mapContainerSelector: MapContainerSelector) {
        guard let mapConfig = mapConfig,
              let mapLocalization = mapLocalization else {
            assertionFailure("mapConfig/mapLocalization should not be nil")
            return
        }
        
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

    func runExternalBrowser(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func runPhoneService(phoneNumberURL: URL) {
        UIApplication.shared.open(phoneNumberURL)
    }
    
    func runAlert(_ title: String? = nil, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        navigationController.present(alertController, animated: true)
    }
}

// MARK: - PermissionCoordinatorDelegate
extension AppCoordinator: PermissionCoordinatorDelegate {
    
    func coordinator(_ coordinator: PermissionCoordinator, customImageWithName name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    func coordinatorDidFinish(_ coordinator: PermissionCoordinator) {
        removeChildCoordinator(coordinator)
        navigationController.dismiss(animated: true)
        
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
        runAlert("Error", message: error.localizedDescription)
    }
}

// MARK: - DemoViewModelDelegate
extension AppCoordinator: DemoViewModelDelegate {
    
    func viewModelViewDidAppear(_ viewModel: DemoViewModel) {
        // Empty
    }
    
    func viewModel(_ viewModel: DemoViewModel, didSelectPOIFor mapContainerKind: DemoViewModel.MapContainerKind) {
        runPOI(mapContainerKind: mapContainerKind)
    }
    
    func viewModel(_ viewModel: DemoViewModel, didSelectRoutingFor mapContainerKind: DemoViewModel.MapContainerKind) {
        runRouting(mapContainerKind: mapContainerKind)
    }
    
    func viewModel(_ viewModel: DemoViewModel, didSelectShareLocationFor mapContainerKind: DemoViewModel.MapContainerKind) {
        runShareLocation(mapContainerSelector: mapContainerSelector(for: mapContainerKind))
    }
}

// MARK: - Private Helpers
private extension AppCoordinator {

    func didSelectActionLink(_ actionLink: ActionLink) {
        switch actionLink.type {
            case .weblink:
                if let urlString = actionLink.actionContent,
                   let url = URL(string: urlString) {
                    runExternalBrowser(url)
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
}

// MARK: - POICoordinatorDelegate
extension AppCoordinator: POICoordinatorDelegate {

    func coordinatorDidFinish(_ coordinator: POICoordinator) {
        removeChildCoordinator(coordinator)
        removeChildMappingDeeplinkHandler(coordinator)
    }

    func coordinator(_ coordinator: POICoordinator, didSelectActionLink actionLink: ActionLink) {
        didSelectActionLink(actionLink)
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didStartHomeToVenueRoutingWith geozoneIdentifiers: Set<String>,
                     destination: HomeToVenueDestination) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didStopHomeToVenueRoutingWith geozoneIdentifiers: Set<String>) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: POICoordinator, customImageWithName name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    func coordinator(_ coordinator: POICoordinator,
                     didRequestMeetingRoomsFor poiIdentifiers: [String],
                     completion: @escaping (Result<[MeetingRoom], Error>) -> Void) {
        requestMeetingRoomStatuses(for: poiIdentifiers, completion: completion)
    }
}

// MARK: - RoutingCoordinatorDelegate
extension AppCoordinator: RoutingCoordinatorDelegate {

    func coordinatorDidFinish(_ coordinator: RoutingCoordinator) {
        removeChildCoordinator(coordinator)
        removeChildMappingDeeplinkHandler(coordinator)
    }

    func coordinator(_ coordinator: RoutingCoordinator, didSelectActionLink actionLink: ActionLink) {
        didSelectActionLink(actionLink)
    }
    
    func coordinator(_ coordinator: RoutingCoordinator,
                     didStartHomeToVenueRoutingWith geozoneIdentifiers: Set<String>,
                     destination: HomeToVenueDestination) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: RoutingCoordinator,
                     didStopHomeToVenueRoutingWith geozoneIdentifiers: Set<String>) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: RoutingCoordinator, customImageWithName name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    func coordinator(_ coordinator: RoutingCoordinator,
                     didRequestMeetingRoomsFor poiIdentifiers: [String],
                     completion: @escaping (Result<[MeetingRoom], Error>) -> Void) {
        requestMeetingRoomStatuses(for: poiIdentifiers, completion: completion)
    }
}

// MARK: - ShareLocationCoordinatorDelegate
extension AppCoordinator: ShareLocationCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ShareLocationCoordinator) {
        removeChildCoordinator(coordinator)
    }

    func coordinator(_ coordinator: ShareLocationCoordinator, didSelectActionLink actionLink: ActionLink) {
        didSelectActionLink(actionLink)
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator,
                     didStartHomeToVenueRoutingWith geozoneIdentifiers: Set<String>,
                     destination: HomeToVenueDestination) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator,
                     didStopHomeToVenueRoutingWith geozoneIdentifiers: Set<String>) {
        // Nothing to be done here in the mapping module
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator, customImageWithName name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator,
                     didRequestShareURLFor location: ShareableLocation,
                     withCompletionHandler completionHandler: @escaping (Result<URL, Error>) -> Void) {
        guard let floorID = location.floorID else {
            completionHandler(.failure(NSError(domain: "Nil floor ID", code: 0, userInfo: nil)))
            return
        }
        
        let deepLink = MappingDeeplink.routeBuilder(
            destination: .coordinate(
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
}

// MARK: - MappingDeeplinkNavigable
extension AppCoordinator: MappingDeeplinkNavigable {
    
    func queryCanOpenDirectly(_ deeplink: MappingDeeplink, completion: @escaping (Bool) -> Void) {
        if !childCoordinators.contains(where: { $0 is MappingDeeplinkNavigable }) {
            // We don't have a child coordinator that can handle the deeplink, so we have to
            // handle it ourselves.
            completion(true)
        } else {
            // We DO have a child coordinator that can handle the deeplink, so complete with false
            // and let the child mapping deeplink navigable handle it.
            completion(false)
        }
    }
    
    func openDeeplink(_ deeplink: MappingDeeplink) -> Bool {
        // If we don't have a child coordinator that can handle the deeplink, we'll need to create one first.
        // Let's just pick the POICoordinator for now.
        if !childCoordinators.contains(where: { $0 is MappingDeeplinkNavigable }) {
            runPOI(mapContainerKind: .building)
        }
        
        guard let mappingDeepLinkHandler = childCoordinators.compactMap({ $0 as? MappingDeeplinkNavigable }).first else {
            assertionFailure("A MappingDeeplinkNavigable must exist in order to follow deeplink: \(deeplink)")
            return false
        }
        
        mappingDeepLinkHandler.followDeeplink(deeplink)
        return true
    }
}
