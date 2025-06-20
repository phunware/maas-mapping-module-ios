//
//  MapConfigProvider.swift
//  PhunwareMappingSample
//
//  Created by Jeff White on 2/3/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareMapping

typealias MapConfigResult = Result<MapConfig, Error>

protocol MapConfigProvider {
    /// Returns the mapping configuration required for rendering the mapping module.
    ///  - Parameter key: The map config key.
    ///  - Parameter completion: Called when the operation completes
    func fetchMapConfig(using key: String, _ completion: @escaping (MapConfigResult) -> Void)
}

// MARK: - StubMapConfigProvider
class StubMapConfigProvider: MapConfigProvider {
    
    private func configJSONData(for key: String) -> Data {
        let jsonString: String
        switch key {
        case "map_config":
            jsonString = Self.configData
        default:
            jsonString = Self.configData
        }
        
        return Data(jsonString.utf8)
    }
    
    func fetchMapConfig(using key: String, _ completion: @escaping (MapConfigResult) -> Void) {

        func parse() -> MapConfig? {
            do {
                return try JSONDecoder().decode(MapConfig.self, from: configJSONData(for: key))
            } catch {
                return nil
            }
        }

        guard let mapConfig = parse() else {
            completion(.failure(CommonError.internalInconsistency))
            return
        }
        
        completion(.success(mapConfig))
    }
}
