//
//  MaasConfig+Organization.swift
//  PhunwareMappingSample
//
//  Created by Troy Stump on 11/3/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation
import PWCore

extension MaasConfig {
    static let phunwareVerticalSolutionsOrganization: MaasConfig = {
        .init(
            environment: .prod,
            applicationID: "<#Your App ID#>", // TODO: Replace with your actual Application ID
            accessKey: "<#Your Access Key#>", // TODO: Replace with your actual Access Key
            organization: "<#Your Organization Name#>" // TODO: Replace with your Organization name
        )
    }()
}
