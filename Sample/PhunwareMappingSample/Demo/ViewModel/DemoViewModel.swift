//
//  DemoViewModel.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareFoundation

protocol DemoViewModelDelegate: AnyObject {
    
    func viewModelViewDidAppear(_ viewModel: DemoViewModel)
    func viewModel(_ viewModel: DemoViewModel, didSelectPOIFor mapContainerKind: DemoViewModel.MapContainerKind)
    func viewModel(_ viewModel: DemoViewModel, didSelectRoutingFor mapContainerKind: DemoViewModel.MapContainerKind)
    func viewModel(_ viewModel: DemoViewModel, didSelectShareLocationFor mapContainerKind: DemoViewModel.MapContainerKind)
}

class DemoViewModel: NSObject {
    
    enum MapContainerKind {
        case campus
        case building
    }
    
    weak var delegate: DemoViewModelDelegate?
    
    func handleViewDidAppear() {
        delegate?.viewModelViewDidAppear(self)
    }
    
    func handleSelection(at indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            delegate?.viewModel(self, didSelectPOIFor: .campus)
            
        case 1:
            delegate?.viewModel(self, didSelectPOIFor: .building)
        
        case 2:
            delegate?.viewModel(self, didSelectRoutingFor: .campus)
        
        case 3:
            delegate?.viewModel(self, didSelectRoutingFor: .building)
        
        case 4:
            delegate?.viewModel(self, didSelectShareLocationFor: .campus)
        
        case 5:
            delegate?.viewModel(self, didSelectShareLocationFor: .building)
        
        default:
            break
        }
    }
}
