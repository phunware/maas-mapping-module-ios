//
//  AppDelegate.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareMapping

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private lazy var appCoordinator: AppCoordinator = {
        let navController = UINavigationController()
        navController.isNavigationBarHidden = false
        return AppCoordinator(navigationController: navController)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        launchApp(with: launchOptions)
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let exampleMatchingURLString = "phunwaremapping://phun.co/some/dynamic/link"
        // Test this out using this URL in Safari:  phunwaremapping://phun.co/some/dynamic/link?map_name=pwsandiego&floor_id=207657&lat=33.021997631720154&long=-117.08250665912037
        if let mappingDeeplink = MappingDeeplink(dynamicLinkURL: url, matchingURLString: exampleMatchingURLString) {
            appCoordinator.followDeeplink(mappingDeeplink)
            return true
        }
        
        // Test this out using this URL in Safari: phunwaremapping://routeBuilder?map_name=pwsandiego&floor_id=207657&lat=33.021997631720154&long=-117.08250665912037
        if let mappingDeeplink = MappingDeeplink(url: url) {
            appCoordinator.followDeeplink(mappingDeeplink)
            return true
        }
        
        return false
    }
}

// MARK: - App Launch
private extension AppDelegate {
    
    func launchApp(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        appCoordinator.start()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appCoordinator.navigationController
        window?.makeKeyAndVisible()
    }
}
