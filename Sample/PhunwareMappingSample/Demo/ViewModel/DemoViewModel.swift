//
//  DemoViewModel.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 1/26/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareFoundation
import PhunwareMapping

protocol DemoViewModelDelegate: AnyObject {
    func viewModelViewDidAppear(_ viewModel: DemoViewModel)
    func viewModel(_ viewModel: DemoViewModel, didSelectMapFor mapConfigInfo: MapConfigInfo, embeddedInTab: Bool)
    func viewModel(_ viewModel: DemoViewModel, didSelectShareLocationFor mapConfigInfo: MapConfigInfo)
    func viewModelDidSelectAppLink(_ viewModel: DemoViewModel)
}

struct Demo {
    let label: String
    let configInfo: MapConfigInfo
    let embeddedInTab: Bool
    let flow: Flow
    
    var iconName: String {
        switch flow {
        case .map: "mappin"
        case .shareLocation: "square.and.arrow.up"
        }
    }
}

class DemoViewModel {
    
    @Published private(set) var info: String

    private(set) var demos = [Demo]()
    weak var delegate: DemoViewModelDelegate?

    init(applicationIdentifier: String,
         organization: String,
         mapConfigKey: String,
         buildingMapConfigInfo: MapConfigInfo,
         campusMapConfigInfo: MapConfigInfo?) {
        info =
        """
        
        App ID: \(applicationIdentifier)
        
        Org: \(organization)
        
        Map Config Key: \(mapConfigKey)
        
        """
        
        var demos: [Demo] = [
            .init(label: "Map (Building)", configInfo: buildingMapConfigInfo, embeddedInTab: false, flow: .map),
            .init(label: "Share My Location (Building)", configInfo: buildingMapConfigInfo, embeddedInTab: false, flow: .shareLocation),
            .init(label: "Mapping Module Tab (Building)", configInfo: buildingMapConfigInfo, embeddedInTab: true, flow: .map)
        ]
        
        if let campusMapConfigInfo {
            demos.insert(.init(label: "Map (Campus)", configInfo: campusMapConfigInfo, embeddedInTab: false, flow: .map), at: 1)
            demos.insert(.init(label: "Share My Location (Campus)", configInfo: campusMapConfigInfo, embeddedInTab: false, flow: .shareLocation), at: 3)
            demos.insert(.init(label: "Mapping Module Tab (Campus)", configInfo: campusMapConfigInfo, embeddedInTab: true, flow: .map), at: 5)
        }
        
        self.demos = demos
    }
    
    func handleViewDidAppear() {
        delegate?.viewModelViewDidAppear(self)
    }
    
    func handleSelection(at indexPath: IndexPath) {
        guard demos.indices.contains(indexPath.row) else { return }
        
        let demo = demos[indexPath.row]
        switch demo.flow {
        case .map:
            delegate?.viewModel(self,
                                didSelectMapFor: demo.configInfo,
                                embeddedInTab: demo.embeddedInTab)
        case .shareLocation:
            delegate?.viewModel(self,
                                didSelectShareLocationFor: demo.configInfo)
        }
    }
    
    func handleAppLinkButtonTap() {
        delegate?.viewModelDidSelectAppLink(self)
    }
}
