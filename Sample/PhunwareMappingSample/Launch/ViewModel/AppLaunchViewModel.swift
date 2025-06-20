//
//  AppLaunchViewModel.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 5/24/22.
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareMapping

protocol AppLaunchViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: AppLaunchViewModel, didFinishLoading mapConfig: MapConfig, mapLocalizationDict: MapLocalizationDictionary)
    func viewModel(_ viewModel: AppLaunchViewModel, didFailWith error: Error)
}

class AppLaunchViewModel {
    
    private let mapConfigProvider: MapConfigProvider
    private let mapLocalizationProvider: MapLocalizationProvider
    private let mapConfigKey: String
    
    weak var delegate: AppLaunchViewModelDelegate?
    
    init(mapConfigProvider: MapConfigProvider,
         mapLocalizationProvider: MapLocalizationProvider,
         mapConfigKey: String) {
        self.mapConfigProvider = mapConfigProvider
        self.mapLocalizationProvider = mapLocalizationProvider
        self.mapConfigKey = mapConfigKey
    }
    
    func handleViewDidLoad() {
        weak var weakSelf = self
        var fetchedMapConfig: MapConfig?
        
        func handleError(_ error: Error) {
            guard let self = weakSelf else { return }
            delegate?.viewModel(self, didFailWith: error)
        }
        
        func fetchMapLocalization(withMapConfig mapConfig: MapConfig) {
            mapLocalizationProvider.fetchMapLocalization(for: mapConfig.languages ?? []) { result in
                guard let self = weakSelf else { return }
                
                switch result {
                case .success(let localizationDict):
                    if let mapConfig = fetchedMapConfig {
                        self.delegate?.viewModel(self, didFinishLoading: mapConfig, mapLocalizationDict: localizationDict)
                    } else {
                        handleError(CommonError.internalInconsistency)
                    }
                case .failure(let error):
                    handleError(error)
                }
            }
        }
        
        UIFont.OpenSans.registerFonts()
        
        mapConfigProvider.fetchMapConfig(using: mapConfigKey) { result in
            switch result {
            case .success(let mapConfig):
                fetchedMapConfig = mapConfig
                
                fetchMapLocalization(withMapConfig: mapConfig)
            case .failure(let error):
                handleError(error)
            }
        }
    }
}
