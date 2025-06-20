//
//  AppLinkViewModel.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 9/21/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation

protocol AppLinkViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: AppLinkViewModel, didSelectAppLink appLink: AppLink)
    func viewModelDidFinish(_ viewModel: AppLinkViewModel)
}

class AppLinkViewModel {
    
    struct AppLinkSection {
        let name: String
        let links: [AppLink]
    }
    
    weak var delegate: AppLinkViewModelDelegate?
    
    let appLinkSections: [AppLinkSection] = [
        .init(
            name: "Map Tab",
            links: [
                .init(.navigation, "mapping/mapId=single_building", supportsExternal: false)!,
                .init(.navigation, "mapping/mapId=multi_building", supportsExternal: false)!
            ]
        ),
        .init(
            name: "Expanded Featured Lists",
            links: [
                .init(.navigation, "mapping/mapId=single_building?view=expandedFeaturedList")!,
                .init(.navigation, "mapping/mapId=multi_building?view=expandedFeaturedList")!
            ]
        ),
        .init(
            name: "Category",
            links: [
                .init(.navigation, "mapping/mapId=single_building?view=category&categoryId=dining&mapConfigKey=map_config")!,
                .init(.navigation, "mapping/mapId=single_building?view=category&categoryId=elevators-escalators&mapConfigKey=map_config")!,
                .init(.navigation, "mapping/mapId=multi_building?view=category&categoryId=dining&mapConfigKey=map_config")!,
                .init(.navigation, "mapping/mapId=multi_building?view=category&categoryId=elevators-escalators&mapConfigKey=map_config")!
            ]
        ),
        .init(
            name: "Route Builder",
            links: [
                .init(.navigation, "mapping/mapId=single_building?view=route&lat=30.27449704096704&long=-97.74920668167968&floorId=710314&mapConfigKey=map_config")!,
                .init(.navigation, "mapping/mapId=multi_building?view=route&lat=30.27452982551991&long=-97.74957492791683&floorId=725453&mapConfigKey=map_config")!
            ]
        ),
        .init(
            name: "Share My Location",
            links: [
                .init(.navigation, "mapping/mapId=single_building?view=shareLocation", supportsExternal: false)!,
                .init(.navigation, "mapping/mapId=multi_building?view=shareLocation", supportsExternal: false)!
            ]
        ),
    ]
    
    func handleAppLinkSelection(_ appLink: AppLink) {
        delegate?.viewModel(self, didSelectAppLink: appLink)
    }
    
    func handleCloseButtonTap() {
        delegate?.viewModelDidFinish(self)
    }
}
