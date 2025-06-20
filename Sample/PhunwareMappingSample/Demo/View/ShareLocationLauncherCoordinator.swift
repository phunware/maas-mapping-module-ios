//
//  ShareLocationLauncherCoordinator.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 10/4/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareFoundation
import PhunwareMapping

class ShareLocationLauncherCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    
    private(set) var mapConfig: MapConfig
    private(set) var mapLocalization: MapLocalization
    private(set) var mapContainerSelector: MapContainerSelector
    private let configInfo: MapConfigInfo
    private let shareLocationURLGenerator: ShareLocationURLGenerator
    
    init(navigationController: UINavigationController,
         mapConfig: MapConfig,
         mapLocalization: MapLocalization,
         mapContainerSelector: MapContainerSelector,
         configInfo: MapConfigInfo,
         shareLocationURLGenerator: ShareLocationURLGenerator) {
        self.navigationController = navigationController
        self.mapConfig = mapConfig
        self.mapLocalization = mapLocalization
        self.mapContainerSelector = mapContainerSelector
        self.configInfo = configInfo
        self.shareLocationURLGenerator = shareLocationURLGenerator
    }
    
    func start() {
        let viewModel = ShareLocationLauncherViewModel(mapConfig: mapConfig,
                                                       mapLocalization: mapLocalization,
                                                       mapContainerSelector: mapContainerSelector)
        let viewController = ShareLocationLauncherViewController(viewModel: viewModel)
        viewModel.delegate = self
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - ShareLocationLauncherViewModelDelegate
extension ShareLocationLauncherCoordinator: ShareLocationLauncherViewModelDelegate {
    
    func viewModelDidLaunchShareLocation(_ viewModel: ShareLocationLauncherViewModel) {
        let childCoordinator = ShareLocationCoordinator(navigationController: navigationController,
                                                        mapConfig: viewModel.mapConfig,
                                                        mapLocalization: viewModel.mapLocalization,
                                                        mapContainerSelector: viewModel.mapContainerSelector,
                                                        mapTheme: MapThemeConfigurator.current.configureTheme(),
                                                        hidesBottomBarWhenPushed: true,
                                                        buildingGroundOverlayRenderers: nil)
        childCoordinator.delegate = self
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
    }
}

// MARK: - ShareLocationCoordinatorDelegate
extension ShareLocationLauncherCoordinator: ShareLocationCoordinatorDelegate {
    
    func coordinatorDidFinish(_ coordinator: ShareLocationCoordinator) {
        removeChildCoordinator(coordinator)
    }
    
    func coordinator(_ coordinator: ShareLocationCoordinator,
                     didRequestShareURLFor location: ShareableLocation,
                     withCompletionHandler completionHandler: @escaping (Result<ShareLocationURLs, Error>) -> Void) {
        shareLocationURLGenerator.generateShareLocationURL(for: location,
                                                           mapConfigKey: configInfo.mapConfigKey,
                                                           withCompletionHandler: completionHandler)
    }
}
