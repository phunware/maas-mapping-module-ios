//
//  ShareLocationURLGenerator.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 10/4/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareMapping

class ShareLocationURLGenerator {
    private let universalLinkDomain: String
        
    init(universalLinkDomain: String) {
        self.universalLinkDomain = universalLinkDomain
    }
    
    func generateShareLocationURL(for location: ShareableLocation, mapConfigKey: String?, withCompletionHandler completionHandler: @escaping (Result<ShareLocationURLs, Error>) -> Void) {
        guard let floorID = location.floorID else {
            completionHandler(.failure(NSError(domain: "Nil floor ID", code: 0, userInfo: nil)))
            return
        }
        
        let appStoreID = "6737143088"
        let androidPackageName = "com.mappingsample.staging"

        guard let iosURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)"),
              let androidURL = URL(string: "https://play.google.com/store/apps/details?id=\(androidPackageName)") else {
            completionHandler(.failure(NSError(domain: "InvalidStoreURL", code: 0)))
            return
        }

        let deepLink = MappingDeeplink.routeBuilder(
            destination: .coordinate(
                mapConfigKey: mapConfigKey,
                mapName: location.mapName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                floorId: floorID
            )
        )
        
        guard let universalLink = deepLink.url(withUniversalLinkDomain: universalLinkDomain) else {
            completionHandler(.failure(NSError(domain: "Invalid share URL", code: 0, userInfo: nil)))
            return
        }
        
        let shareLocationURLs = ShareLocationURLs(
            universalLink: universalLink,
            iOSAppStoreLink: iosURL,
            androidPlayStoreLink: androidURL
        )

        completionHandler(.success(shareLocationURLs))
    }
}
