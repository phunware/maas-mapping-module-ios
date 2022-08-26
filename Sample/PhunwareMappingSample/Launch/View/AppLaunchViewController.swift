//
//  AppLaunchViewController.swift
//  PhunwareMappingSample
//
//  Copyright © 2022 Phunware, Inc. All rights reserved.
//

import UIKit
import PhunwareFoundation

class AppLaunchViewController: UIViewController {
    
    var viewModel: AppLaunchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard viewModel != nil else {
            assertionFailure("`viewModel` is required for `\(Self.self)` to work.")
            return
        }
        
        viewModel.handleViewDidLoad()
    }
}

// MARK: - StoryboardInitializable
extension AppLaunchViewController: StoryboardInitializable {
    public static var storyboardName: String {
        "AppLaunch"
    }
}
