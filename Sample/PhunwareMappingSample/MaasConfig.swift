//
//  MaasConfig.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import Foundation
import PWCore

/// A type that represents MaaS configurations.
public struct MaasConfig {
    
    let environment: PWEnvironment
    let applicationID: String
    let accessKey: String
    
    public init(environment: PWEnvironment,
                applicationID: String,
                accessKey: String) {
        self.environment = environment
        self.applicationID = applicationID
        self.accessKey = accessKey
    }
}
