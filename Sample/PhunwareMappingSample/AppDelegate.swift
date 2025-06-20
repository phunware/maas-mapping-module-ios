//
//  AppDelegate.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 1/25/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareMapping

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    private lazy var appCoordinator: AppCoordinator = {
        let navController = UINavigationController()
        navController.isNavigationBarHidden = false
        return AppCoordinator(navigationController: navController)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupFirebase()
        launchApp(with: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let messageMetadata = response.notification.request.content.userInfo["messageMetadata"] as? String else {
            return
        }
        
        guard let data = messageMetadata.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? NSDictionary else {
            return
        }
        
        if let urlString = dict["mappingDeeplinkURL"] as? String,
           let url = URL(string: urlString) {
            if let mappingDeeplink = MappingDeeplink(url: url) {
                appCoordinator.followDeeplink(mappingDeeplink)
            }
        }
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Test this out using this URL in Safari: phunwaremapping://mapping/routeBuilder?map_name=pwsandiego&floor_id=207657&lat=33.021997631720154&long=-117.08250665912037
        if let mappingDeeplink = MappingDeeplink(url: url) {
            appCoordinator.followDeeplink(mappingDeeplink)
            return true
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

        if let mappingDeeplink = MappingDeeplink(universalLinkURL: url, matchingURLString: appCoordinator.shareMyLocationMatchingURLString) {
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

// MARK: - Firebase
private extension AppDelegate {
    
    func setupFirebase() {
        
    }
}
