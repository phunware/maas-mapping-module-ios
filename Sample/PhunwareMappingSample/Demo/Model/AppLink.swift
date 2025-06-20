//
//  AppLink.swift
//  PhunwareMappingSample
//
//  Created by Henry Peng on 9/22/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation
import PhunwareCorePlugin

struct AppLink {
    let actionType: String
    let actionContent: String
    let supportsExternal: Bool
    
    var deeplink: Deeplink? {
        .init(contentType: actionType, contentAddress: actionContent)
    }
    
    init?(_ actionType: String, _ content: String, supportsExternal: Bool = true) {
        self.actionType = actionType
        self.actionContent = content
        self.supportsExternal = supportsExternal
    }
}

extension String {
    static let navigation = "navigation"
}
