//
//  ShareLocationLauncherViewModel.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 10/4/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareFoundation
import PhunwareMapping

protocol ShareLocationLauncherViewModelDelegate: AnyObject {
    func viewModelDidLaunchShareLocation(_ viewModel: ShareLocationLauncherViewModel)
}

class ShareLocationLauncherViewModel {
    private(set) var mapConfig: MapConfig
    private(set) var mapLocalization: MapLocalization
    private(set) var mapContainerSelector: MapContainerSelector
    weak var delegate: ShareLocationLauncherViewModelDelegate?
    
    init(mapConfig: MapConfig, mapLocalization: MapLocalization, mapContainerSelector: MapContainerSelector) {
        self.mapConfig = mapConfig
        self.mapLocalization = mapLocalization
        self.mapContainerSelector = mapContainerSelector
    }
    
    func handleShareLocationButtonTap() {
        delegate?.viewModelDidLaunchShareLocation(self)
    }
}
