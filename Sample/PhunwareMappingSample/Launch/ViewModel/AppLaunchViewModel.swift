//
//  AppLaunchViewModel.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareMapping

protocol AppLaunchViewModelDelegate: AnyObject {
    
    func viewModel(_ viewModel: AppLaunchViewModel, didFinishLoading mapConfig: MapConfig, mapLocalizationDict: MapLocalizationDictionary)
    func viewModel(_ viewModel: AppLaunchViewModel, didFailWith error: Error)
}

class AppLaunchViewModel {
    
    private let mapConfigProvider: MapConfigProvider
    private let mapLocalizationProvider: MapLocalizationProvider
    
    weak var delegate: AppLaunchViewModelDelegate?
    
    init(mapConfigProvider: MapConfigProvider,
         mapLocalizationProvider: MapLocalizationProvider) {
        self.mapConfigProvider = mapConfigProvider
        self.mapLocalizationProvider = mapLocalizationProvider
    }
    
    func handleViewDidLoad() {
        weak var weakSelf = self
        var fetchedMapConfig: MapConfig?
        
        func handleError(_ error: Error) {
            guard let self = weakSelf else { return }
            delegate?.viewModel(self, didFailWith: error)
        }
        
        func fetchMapLocalization() {
            mapLocalizationProvider.fetchMapLocalization(for: []) { result in
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
        
        mapConfigProvider.fetchMapConfig { result in
            switch result {
            case .success(let mapConfig):
                fetchedMapConfig = mapConfig
                
                fetchMapLocalization()
            case .failure(let error):
                handleError(error)
            }
        }
    }
}
