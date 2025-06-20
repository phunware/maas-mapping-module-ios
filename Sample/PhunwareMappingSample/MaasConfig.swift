//
//  MaasConfig.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 1/28/21.
//  Copyright © 2021 Phunware, Inc. All rights reserved.
//

import Foundation
import PWCore

/// A type that represents MaaS configurations.
public struct MaasConfig {
    let environment: PWEnvironment
    let applicationID: String
    let accessKey: String
    let organization: String
    
    public init(environment: PWEnvironment,
                applicationID: String,
                accessKey: String,
                organization: String) {
        self.environment = environment
        self.applicationID = applicationID
        self.accessKey = accessKey
        self.organization = organization
    }
}
