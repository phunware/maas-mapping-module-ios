//
//  URL+App.swift
//  PhunwareMappingSample
//
//  Created by Troy Stump on 8/25/23.
//  Copyright © 2023 Phunware, Inc. All rights reserved.
//

import Foundation

extension URL {
    
    private static let supportedURLSchemes = ["https", "http"]
    
    var canOpenInSFSafariViewController: Bool {
        guard let scheme = scheme else {
            return false
        }
        
        return Self.supportedURLSchemes.contains(scheme.lowercased())
    }
}
